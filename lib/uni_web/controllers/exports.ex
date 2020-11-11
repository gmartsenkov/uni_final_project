defmodule UniWeb.ExportsController do
  use UniWeb, :controller

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
    csv = Article
    |> Articles.filter(Map.to_list(params))
    |> Articles.graph()
    |> ArticleExporter.call()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"articles.csv\"")
    |> send_resp(200, csv)
  end

  def monographs(conn, params) do
    csv = Monograph
    |> Monographs.filter(Map.to_list(params))
    |> Monographs.graph()
    |> MonographExporter.call()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"monographs.csv\"")
    |> send_resp(200, csv)
  end

  def projects(conn, params) do
    csv = Project
    |> Projects.filter(Map.to_list(params))
    |> Projects.graph()
    |> ProjectExporter.call()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"projects.csv\"")
    |> send_resp(200, csv)
  end

  def conferences(conn, params) do
    csv = Conference
    |> Conferences.filter(Map.to_list(params))
    |> Conferences.graph()
    |> ConferenceExporter.call()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"conferences.csv\"")
    |> send_resp(200, csv)
  end
end
