defmodule Uni.Exports.Conferences do
  @columns ["Създател", "Тема", "Страници", "Тип", "Докладван", "Публикуван"]

  def call(conferences) do
    conferences
    |> Enum.map(&row/1)
    |> List.insert_at(0, @columns)
    |> CSV.encode()
    |> Enum.into("")
  end

  defp row(conference) do
    [
      conference.owner.name,
      conference.name,
      "#{conference.page_start} - #{conference.page_end}",
      type(conference.type),
      bool(conference.reported),
      bool(conference.published)
    ]
  end

  def bool(true), do: "Да"
  def bool(false), do: "Не"

  def type("national"), do: "Национален"
  def type("international"), do: "Международен"
end
