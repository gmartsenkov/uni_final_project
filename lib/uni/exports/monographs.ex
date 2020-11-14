defmodule Uni.Exports.Monographs do
  @columns ["Създател", "Автори", "Име", "Издателство", "Година"]

  def call(monographs) do
    monographs
    |> Enum.map(&row/1)
    |> List.insert_at(0, @columns)
    |> CSV.encode()
    |> Enum.into("")
  end

  defp row(monograph) do
    [
      monograph.owner.name,
      authors(monograph),
      monograph.name,
      monograph.publisher,
      monograph.year
    ]
  end

  defp authors(%{authors: authors}) do
    authors
    |> Enum.map(&Map.get(&1, :name))
    |> Enum.join(", ")
  end
end
