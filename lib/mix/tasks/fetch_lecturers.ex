defmodule Mix.Tasks.FetchLecturers do
  use Mix.Task

  @max_concurrency System.schedulers_online * 2
  @lecturer_regex Regex.compile!("<a href=\"(.*)\">(.*)<\/a>")
  @email_regex Regex.compile!("<strong>(.*)<img src=\"\/Content\/images\/at\.png\" \/>(.*?)<\/strong>", "s")

  @shortdoc "Fetch the lecturers and instert them into the database"

  def run(_) do
    Mix.Task.run("app.start")

    lecturer_links = get_lecturers_links()

    IO.puts("Fetching lecturers info...")
    IO.puts("--------------------------")

    lecturers = lecturer_links
    |> Task.async_stream(&get_user/1, max_concurrency: @max_concurrency)
    |> Tqdm.tqdm(total: Enum.count(lecturer_links))
    |> Enum.to_list()

    IO.puts("--------------------------")
    IO.puts("Saving lecturers to the database...")

    lecturers
    |> Task.async_stream(&insert_user/1, max_concurrency: @max_concurrency)
    |> Tqdm.tqdm(total: Enum.count(lecturer_links))
    |> Enum.to_list()

    IO.puts("--------------------------")
    IO.puts("DONE")

  end

  defp get_lecturers_links do
    body = HTTPoison.get!("https://ais.swu.bg/profiles") |> Map.get(:body)

    Regex.scan(@lecturer_regex, body)
    |> Enum.filter(&is_user?/1)
  end

  defp insert_user({:ok, lecturer}) do
    Uni.Users.create_user(
      Map.put(lecturer, :password, Bcrypt.hash_pwd_salt("1234"))
    )
  end

  defp get_user([_, link, name]) do
    body = HTTPoison.get!("https://ais.swu.bg/#{link}", [], follow_redirect: true) |> Map.get(:body)
    [_match, first, domain] = Regex.run(@email_regex, body)

    email = [first, domain]
    |> Enum.map(&String.trim/1)
    |> Enum.join("@")

    %{name: name, email: email}
  end

  defp is_user?([text | _]) do
    String.contains?(text, "GetProfileName")
  end
end
