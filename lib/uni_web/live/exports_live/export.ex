defmodule ArticlesForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :selection
    field :faculty
    field :department
    field :type
    field :scopus
    field :wofscience
    field :start_date
    field :end_date
  end

  def changeset(attrs) do
    cast(%ArticlesForm{}, attrs, [
      :selection,
      :faculty,
      :department,
      :type,
      :scopus,
      :wofscience,
      :start_date,
      :end_date
    ])
  end
end

defmodule MonographsForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :selection
    field :faculty
    field :department
    field :start_date
    field :end_date
  end

  def changeset(attrs) do
    cast(%MonographsForm{}, attrs, [:selection, :faculty, :department, :start_date, :end_date])
  end
end

defmodule ProjectsForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :selection
    field :faculty
    field :department
    field :project_type
    field :financing_type
  end

  def changeset(attrs) do
    cast(%ProjectsForm{}, attrs, [
      :selection,
      :faculty,
      :department,
      :project_type,
      :financing_type
    ])
  end
end

defmodule ConferencesForm do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field :selection
    field :faculty
    field :department
    field :reported
    field :published
    field :type
  end

  def changeset(attrs) do
    cast(%ConferencesForm{}, attrs, [:selection, :faculty, :department, :reported, :published])
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
    socket = assign_defaults(socket, session)
    user = socket.assigns.current_user

    {:ok,
     socket
     |> assign(:faculties, faculties())
     |> assign(:page_title, gettext("Reports"))
     |> assign(:faculty_id, "all")
     |> assign(:articles_params, params_for_role(%{}, user))
     |> assign(:monographs_params, params_for_role(%{}, user))
     |> assign(:projects_params, params_for_role(%{}, user))
     |> assign(:conferences_params, params_for_role(%{}, user))
     |> assign(:articles_form, ArticlesForm.changeset(%{faculty: "all"}))
     |> assign(:monographs_form, MonographsForm.changeset(%{faculty: "all"}))
     |> assign(:projects_form, ProjectsForm.changeset(%{faculty: "all"}))
     |> assign(:conferences_form, ConferencesForm.changeset(%{faculty: "all"}))
     |> assign(:articles_count, Articles.count(default_filter(Article, user)))
     |> assign(:monographs_count, Monographs.count(default_filter(Monograph, user)))
     |> assign(:projects_count, Projects.count(default_filter(Project, user)))
     |> assign(:conferences_count, Conferences.count(default_filter(Conference, user)))
     |> assign(:tab, "articles")}
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :tab, tab)}
  end

  @impl true
  def handle_event("articles_change", %{"articles_form" => params}, socket) do
    params = params |> guard_params() |> parse_selection(socket.assigns.current_user)

    params =
      params
      |> params_for_role(socket.assigns.current_user)
      |> Map.merge(params)

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
    params = params |> guard_params() |> parse_selection(socket.assigns.current_user)

    params =
      params
      |> params_for_role(socket.assigns.current_user)
      |> Map.merge(params)

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
    params = params |> guard_params() |> parse_selection(socket.assigns.current_user)

    params =
      params
      |> params_for_role(socket.assigns.current_user)
      |> Map.merge(params)

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
    params = params |> guard_params() |> parse_selection(socket.assigns.current_user)

    params =
      params
      |> params_for_role(socket.assigns.current_user)
      |> Map.merge(params)

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

  defp default_filter(Article, user) do
    Articles.filter(Article, Map.to_list(params_for_role(%{}, user)))
  end

  defp default_filter(Monograph, user) do
    Monographs.filter(Monograph, Map.to_list(params_for_role(%{}, user)))
  end

  defp default_filter(Conference, user) do
    Conferences.filter(Conference, Map.to_list(params_for_role(%{}, user)))
  end

  defp default_filter(Project, user) do
    Projects.filter(Project, Map.to_list(params_for_role(%{}, user)))
  end

  defp select_type(%{head_department: true, head_faculty: true}) do
    [
      {gettext("Myself"), "myself"},
      {gettext("Faculty"), "faculty"},
      {gettext("Department"), "department"}
    ]
  end

  defp select_type(%{head_department: true}) do
    [
      {gettext("Myself"), "myself"},
      {gettext("Department"), "department"}
    ]
  end

  defp select_type(%{head_faculty: true}) do
    [
      {gettext("Myself"), "myself"},
      {gettext("Faculty"), "faculty"}
    ]
  end

  defp parse_selection(%{"selection" => "myself"} = params, user),
    do: Map.put(params, "user", user.id)

  defp parse_selection(%{"selection" => "faculty"} = params, user),
    do: Map.put(params, "faculty", user.faculty_id)

  defp parse_selection(%{"selection" => "department"} = params, user),
    do: Map.put(params, "department", user.department_id)

  defp parse_selection(params, _user), do: params

  defp params_for_role(_params, %{admin: true}), do: %{}
  defp params_for_role(%{"selection" => _selection}, _user), do: %{}
  defp params_for_role(_params, user), do: %{"user" => user.id}

  defp active?(tab, expected) when tab == expected, do: "active"
  defp active?(_tab, _expected), do: ""
end
