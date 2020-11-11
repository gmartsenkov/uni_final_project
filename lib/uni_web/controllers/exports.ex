defmodule UniWeb.ExportsController do
  use UniWeb, :controller

  alias Uni.Articles.Article
  alias Uni.Articles
  alias Uni.Exports.Articles, as: Exporter

  def articles(conn, params) do
    IO.inspect(params)

    csv = Article
    |> Articles.filter(Map.to_list(params))
    |> Articles.graph()
    |> Exporter.call()

    conn
    |> put_resp_content_type("text/csv")
    |> put_resp_header("content-disposition", "attachment; filename=\"articles.csv\"")
    |> send_resp(200, csv)
  end
end
