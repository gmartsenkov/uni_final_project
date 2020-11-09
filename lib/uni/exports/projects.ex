defmodule Uni.Exports.Projects do
  @columns ["Създател", "Име", "Проект №", "Роля", "Вид", "Финансиране"]

  def call(projects) do
    projects
    |> Enum.map(&row/1)
    |> List.insert_at(0, @columns)
    |> CSV.encode()
    |> Enum.into("")
  end

  defp row(project) do
    [
      project.owner.name,
      project.name,
      project.project_id,
      project.participation_role,
      type(project.project_type),
      financing(project.financing_type),
    ]
  end

  def bool(true), do: "Да"
  def bool(false), do: "Не"

  def type("national"), do: "Национален"
  def type("international"), do: "Международен"

  def financing("internal"), do: "Вътрешно"
  def financing("external"), do: "Външно"
end
