defmodule UniWeb.ExportsController do
  use UniWeb, :controller

  @bom :unicode.encoding_to_bom(:utf8)

  alias Uni.Articles.Article
  alias Uni.Articles
  alias Uni.Monographs.Monograph
  alias Uni.Monographs
  alias Uni.Projects.Project
  alias Uni.Projects
  alias Uni.Conferences.Conference
  alias Uni.Conferences
  alias Uni.Exports.Articles, as: ArticleExporter
  alias Uni.Exports.Monographs, as: MonographExporter
  alias Uni.Exports.Projects, as: ProjectExporter
  alias Uni.Exports.Conferences, as: ConferenceExporter

  def articles(conn, params) do
    csv =
      Article
      |> Articles.filter(Map.to_list(params))
      |> Articles.graph()
      |> ArticleExporter.call()

    send_download(
      conn,
      {:binary, Enum.join([@bom, csv])},
      content_type: "application/csv; charset=utf-8",
      filename: "articles.csv"
    )
  end

  def monographs(conn, params) do
    csv =
      Monograph
      |> Monographs.filter(Map.to_list(params))
      |> Monographs.graph()
      |> MonographExporter.call()

    send_download(
      conn,
      {:binary, Enum.join([@bom, csv])},
      content_type: "application/csv; charset=utf-8",
      filename: "monographs.csv"
    )
  end

  def projects(conn, params) do
    csv =
      Project
      |> Projects.filter(Map.to_list(params))
      |> Projects.graph()
      |> ProjectExporter.call()

    send_download(
      conn,
      {:binary, Enum.join([@bom, csv])},
      content_type: "application/csv; charset=utf-8",
      filename: "projects.csv"
    )
  end

  def conferences(conn, params) do
    csv =
      Conference
      |> Conferences.filter(Map.to_list(params))
      |> Conferences.graph()
      |> ConferenceExporter.call()

    send_download(
      conn,
      {:binary, Enum.join([@bom, csv])},
      content_type: "application/csv; charset=utf-8",
      filename: "conferences.csv"
    )
  end
end
