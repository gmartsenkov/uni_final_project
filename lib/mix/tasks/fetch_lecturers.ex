defmodule Mix.Tasks.FetchLecturers do
  use Mix.Task

  @email_regex Regex.compile!(
                 "<strong>(.*)<img src=\"\/Content\/images\/at\.png\" \/>(.*?)<\/strong>",
                 "s"
               )

  @shortdoc "Fetch the lecturers and instert them into the database"

  def run(_) do
    Mix.Task.run("app.start")

    IO.puts("Loading...")
    IO.puts("--------------------------")

    data = get_data()

    IO.puts("Fetching lecturers info...")
    IO.puts("--------------------------")

    data
    |> departments_structure()
    |> save_departments_info()

    data
    |> Task.async_stream(&get_users/1, max_concurrency: Enum.count(data), timeout: :infinity)
    |> Tqdm.tqdm(total: Enum.count(data))
    |> Enum.to_list()
    |> Enum.map(&(Tuple.to_list(&1) |> List.last))
    |> List.flatten()
    |> Task.async_stream(&insert_user/1, timeout: :infinity)
    |> Tqdm.tqdm(total: Enum.count(data))
    |> Enum.to_list()

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

    body
    |> Floki.parse_document!()
    |> Floki.find("li a")
    |> Enum.chunk_by(&is_faculty?/1)
    |> Enum.chunk_every(2)
    |> Enum.map(&map_faculty/1)
  end

  defp save_departments_info(data) do
    Enum.each(data, fn faculty ->
      case Uni.Faculties.faculty_by_name(faculty[:name]) do
        nil ->
          new = Uni.Repo.insert!(%Uni.Faculties.Faculty{name: faculty[:name]})
          save_departments_for_faculty(new, faculty[:departments])

        found ->
          save_departments_for_faculty(found, faculty[:departments])
      end
    end)
  end

  defp departments_structure(data) do
    Enum.map(data, fn faculty ->
      %{name: faculty[:faculty], departments: Enum.map(faculty[:data], &Map.get(&1, :department))}
    end)
  end

  defp save_departments_for_faculty(%Uni.Faculties.Faculty{} = faculty, departments) do
    Enum.each(departments, fn department_name ->
      case Uni.Faculties.department_by_name(department_name) do
        nil ->
          Uni.Repo.insert!(%Uni.Faculties.Department{
            name: department_name,
            faculty_id: faculty.id
          })

        _ ->
          true
      end
    end)
  end

  defp map_faculty([[faculty_link], rest]) do
    %{
      faculty: Floki.text(faculty_link),
      data: map_departments(rest)
    }
  end

  defp map_departments(data) do
    data
    |> Enum.chunk_by(&is_department?/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [departments, people] ->
      department = List.last(departments)

      %{department: Floki.text(department), people: people}
    end)
  end

  defp is_faculty?(link) do
    href = Floki.attribute(link, "href") |> List.first()

    String.contains?(href, "faculty") && !String.contains?(href, "department")
  end

  defp is_department?(link) do
    href = Floki.attribute(link, "href") |> List.first()

    String.contains?(href, "department")
  end

  defp insert_user(lecturer) do
    faculty = Uni.Faculties.faculty_by_name(lecturer[:faculty])
    department = Uni.Faculties.department_by_name(lecturer[:department])

    case Uni.Users.by_email(lecturer[:email]) do
      nil ->
        Uni.Repo.insert!(%Uni.Users.User{
          email: lecturer[:email],
          name: lecturer[:name],
          password: Bcrypt.hash_pwd_salt("1234"),
          department_id: department.id,
          faculty_id: faculty.id
        })
    end
  end

  defp get_users(faculty) do
    Map.get(faculty, :data)
    |> Enum.map(fn department ->
      department
      |> Map.get(:people)
      |> Enum.map(fn person -> get_user(faculty, department, person) end)
    end)
    |> List.flatten()
    |> List.flatten()
  end

  defp get_user(faculty, department, user_link) do
    link = Floki.attribute(user_link, "href") |> List.first()
    name = Floki.text(user_link)

    body =
      HTTPoison.get!("https://ais.swu.bg/#{link}", [], follow_redirect: true) |> Map.get(:body)

    [_match, first, domain] = Regex.run(@email_regex, body)

    email =
      [first, domain]
      |> Enum.map(&String.trim/1)
      |> Enum.join("@")

    %{name: name, email: email, faculty: faculty[:faculty], department: department[:department]}
  end
end
