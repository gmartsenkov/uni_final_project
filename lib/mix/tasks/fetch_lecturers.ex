defmodule Mix.Tasks.FetchLecturers do
  use Mix.Task
  import Meeseeks.CSS

  @email_regex Regex.compile!("<strong>(.*)<img src=\"\/Content\/images\/at\.png\" \/>(.*?)<\/strong>", "s")

  @shortdoc "Fetch the lecturers and instert them into the database"

  def run(_) do
    Mix.Task.run("app.start")

    IO.puts("Loading...")
    IO.puts("--------------------------")

    data = get_data()

    IO.puts("Fetching lecturers info...")
    IO.puts("--------------------------")

    data
    |> Task.async_stream(&get_users/1, max_concurrency: Enum.count(data), timeout: :infinity)
    |> Tqdm.tqdm(total: Enum.count(data))
    |> Enum.to_list()
    |> IO.inspect()

    # lecturers = lecturer_links
    # |> Task.async_stream(&get_user/1, max_concurrency: @max_concurrency)
    # |> Tqdm.tqdm(total: Enum.count(lecturer_links))
    # |> Enum.to_list()

    # IO.puts("--------------------------")
    # IO.puts("Saving lecturers to the database...")

    # lecturers
    # |> Task.async_stream(&insert_user/1, max_concurrency: @max_concurrency)
    # |> Tqdm.tqdm(total: Enum.count(lecturer_links))
    # |> Enum.to_list()

    # IO.puts("--------------------------")
    # IO.puts("DONE")

  end

  def get_data do
    body = HTTPoison.get!("https://ais.swu.bg/profiles").body

    Meeseeks.all(body, css("li a"))
    |> Enum.chunk_by(&is_faculty?/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&map_faculty/1)
  end

  def map_faculty([[faculty_link], rest]) do
    %{
      faculty: Meeseeks.text(faculty_link),
      data: map_departments(rest)
    }
  end

  def map_departments(data) do
    data
    |> Enum.chunk_by(&is_department?/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [departments, people] ->
      department = List.last(departments)

      %{department: Meeseeks.text(department), people: people}
    end)
  end

  def is_faculty?(link) do
    href = Meeseeks.attr(link, "href")

    String.contains?(href, "faculty") && !String.contains?(href, "department")
  end

  def is_department?(link) do
    href = Meeseeks.attr(link, "href")

    String.contains?(href, "department")
  end

  defp insert_user({:ok, lecturer}) do
    Uni.Users.create_user(
      Map.put(lecturer, :password, Bcrypt.hash_pwd_salt("1234"))
    )
  end

  def get_users(faculty) do
    Map.get(faculty, :data)
    |> Enum.map(fn department ->
      department
      |> Map.get(:people)
      |> Enum.map(fn person -> get_user(faculty, department, person) end)
    end)
    |> List.flatten()
    |> List.flatten()
  end

  def get_user(faculty, department, user_link) do
    link = Meeseeks.attr(user_link, "href")
    name = Meeseeks.text(user_link)

    body = HTTPoison.get!("https://ais.swu.bg/#{link}", [], follow_redirect: true) |> Map.get(:body)

    [_match, first, domain] = Regex.run(@email_regex, body)

    email = [first, domain]
    |> Enum.map(&String.trim/1)
    |> Enum.join("@")

    %{name: name, email: email, faculty: faculty[:faculty], department: department[:department]}
  end
end
