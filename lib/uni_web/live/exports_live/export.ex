defmodule ArticlesForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :faculty
    field :department
    field :type
    field :scopus
    field :wofscience
    field :start_date
    field :end_date
  end

  def changeset(attrs) do
    cast(%ArticlesForm{}, attrs, [:faculty, :department, :type, :scopus, :wofscience, :start_date, :end_date])
  end
end

defmodule UniWeb.ExportsLive.Export do
  use UniWeb, :live_view

  alias Uni.Articles.Article
  alias Uni.Articles
  alias Uni.Faculties

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(:faculties, faculties())
     |> assign(:faculty_id, "all")
     |> assign(:articles_params, %{})
     |> assign(:articles_form, ArticlesForm.changeset(%{}))
     |> assign(:articles_count, Articles.count(Article))
     |> assign(:tab, "articles")}
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  @impl true
  def handle_event("articles_change", %{"articles_form" => params}, socket) do
    articles_count =
      Article
      |> Articles.filter(Map.to_list(params))
      |> Articles.count()

    {:noreply,
     socket
     |> assign(:faculty_id, params["faculty"])
     |> assign(:articles_form, ArticlesForm.changeset(params))
     |> assign(:articles_params, params)
     |> assign(:articles_count, articles_count)}
  end

  defp faculties() do
    Faculties.faculties()
    |> Enum.map(fn f -> {f.name, f.id} end)
    |> List.insert_at(0, {gettext("All"), "all"})
  end

  defp departments("all"), do: [{gettext("All"), "all"}]

  defp departments(faculty_id) do
    Faculties.departments(%{id: faculty_id})
    |> Enum.map(fn f -> {f.name, f.id} end)
    |> List.insert_at(0, {gettext("All"), "all"})
  end

  defp boolean_choices() do
    [
      {gettext("All"), "all"},
      {gettext("Yes"), "true"},
      {gettext("No"), "false"}
    ]
  end

  def types() do
    [
      {gettext("All"), "all"},
      {gettext("National"), "national"},
      {gettext("International"), "international"}
    ]
  end

  defp active?(tab, expected) when tab == expected, do: "active"
  defp active?(_tab, _expected), do: ""
end
