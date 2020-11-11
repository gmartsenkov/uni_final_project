defmodule UniWeb.ExportsController do
  use UniWeb, :controller

  alias Uni.Articles.Article
  alias Uni.Articles
  alias Uni.Monographs.Monograph
  alias Uni.Monographs
  alias Uni.Exports.Articles, as: ArticleExporter
  alias Uni.Exports.Monographs, as: MonographExporter

  def articles(conn, params) do
    IO.inspect(params)

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
    IO.inspect(params)

    csv = Monograph
    |> Monographs.filter(Map.to_list(params))
    |> Monographs.graph()
    |> MonographExporter.call()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"monographs.csv\"")
    |> send_resp(200, csv)
  end
end
