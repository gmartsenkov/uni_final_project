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

defmodule MonographsForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :faculty
    field :department
    field :start_date
    field :end_date
  end

  def changeset(attrs) do
    cast(%MonographsForm{}, attrs, [:faculty, :department, :start_date, :end_date])
  end
end

defmodule ProjectsForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :faculty
    field :department
    field :project_type
    field :financing_type
  end

  def changeset(attrs) do
    cast(%ProjectsForm{}, attrs, [:faculty, :department, :project_type, :financing_type])
  end
end

defmodule ConferencesForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :faculty
    field :department
    field :reported
    field :published
    field :type
  end

  def changeset(attrs) do
    cast(%ConferencesForm{}, attrs, [:faculty, :department, :reported, :published])
  end
end

defmodule UniWeb.ExportsLive.Export do
  use UniWeb, :live_view

  alias Uni.Articles.Article
  alias Uni.Articles
  alias Uni.Monographs.Monograph
  alias Uni.Monographs
  alias Uni.Projects.Project
  alias Uni.Projects
  alias Uni.Conferences.Conference
  alias Uni.Conferences

  alias Uni.Faculties

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     socket
     |> assign_defaults(session)
     |> assign(:faculties, faculties())
     |> assign(:faculty_id, "all")
     |> assign(:articles_params, %{})
     |> assign(:monographs_params, %{})
     |> assign(:projects_params, %{})
     |> assign(:conferences_params, %{})
     |> assign(:articles_form, ArticlesForm.changeset(%{faculty: "all"}))
     |> assign(:monographs_form, MonographsForm.changeset(%{faculty: "all"}))
     |> assign(:projects_form, ProjectsForm.changeset(%{faculty: "all"}))
     |> assign(:conferences_form, ConferencesForm.changeset(%{faculty: "all"}))
     |> assign(:articles_count, Articles.count(Article))
     |> assign(:monographs_count, Monographs.count(Monograph))
     |> assign(:projects_count, Projects.count(Project))
     |> assign(:conferences_count, Conferences.count(Conference))
     |> assign(:tab, "articles")}
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  @impl true
  def handle_event("articles_change", %{"articles_form" => params}, socket) do
    params = guard_params(params)
    articles_count =
      Article
      |> Articles.filter(Map.to_list(params))
      |> Articles.count()

    {:noreply,
     socket
     |> assign(:articles_form, ArticlesForm.changeset(params))
     |> assign(:articles_params, params)
     |> assign(:articles_count, articles_count)}
  end

  @impl true
  def handle_event("monographs_change", %{"monographs_form" => params}, socket) do
    params = guard_params(params)
    monographs_count =
      Monograph
      |> Monographs.filter(Map.to_list(params))
      |> Monographs.count()

    {:noreply,
     socket
     |> assign(:monographs_form, MonographsForm.changeset(params))
     |> assign(:monographs_params, params)
     |> assign(:monographs_count, monographs_count)}
  end

  @impl true
  def handle_event("projects_change", %{"projects_form" => params}, socket) do
    params = guard_params(params)
    projects_count =
      Project
      |> Projects.filter(Map.to_list(params))
      |> Projects.count()

    {:noreply,
     socket
     |> assign(:projects_form, ProjectsForm.changeset(params))
     |> assign(:projects_params, params)
     |> assign(:projects_count, projects_count)}
  end

  @impl true
  def handle_event("conferences_change", %{"conferences_form" => params}, socket) do
    params = guard_params(params)
    conferences_count =
      Conference
      |> Conferences.filter(Map.to_list(params))
      |> Conferences.count()

    {:noreply,
     socket
     |> assign(:conferences_form, ConferencesForm.changeset(params))
     |> assign(:conferences_params, params)
     |> assign(:conferences_count, conferences_count)}
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

  def financing_types() do
    [
      {gettext("All"), "all"},
      {gettext("Internal"), "internal"},
      {gettext("External"), "external"}
    ]
  end

  def guard_params(params) do
    if Map.get(params, "faculty") == "all" do
      Map.put(params, "department", "all")
    else
      params
    end
  end

  defp active?(tab, expected) when tab == expected, do: "active"
  defp active?(_tab, _expected), do: ""
end
