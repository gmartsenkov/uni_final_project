defmodule Uni.Exports.Articles do
  @columns ["Създател", "Автори", "Заглавие", "Издателство", "Година", "Тип", "Scopus", "Web of Science"]

  def call(articles) do
    articles
    |> Enum.map(&row/1)
    |> List.insert_at(0, @columns)
    |> CSV.encode()
    |> Enum.into("")
  end

  defp row(article) do
    [
      article.owner.name,
      authors(article),
      article.name,
      article.publisher,
      article.year,
      type(article.type),
      bool(article.scopus),
      bool(article.wofscience)
    ]
  end

  defp authors(%{authors: authors}) do
    authors
    |> Enum.map(&Map.get(&1, :name))
    |> Enum.join(", ")
  end

  def bool(true), do: "Да"
  def bool(false), do: "Не"

  def type("national"), do: "Национален"
  def type("international"), do: "Международен"
end
