defmodule UniWeb.ArticleLive.FormComponent do
  use UniWeb, :live_component

  alias Uni.Articles

  @impl true
  def mount(socket) do
    valid_types = ["National": "national", "International": "international"]
    {:ok, assign(socket, valid_types: valid_types)}
  end

  @impl true
  def update(%{article: article} = assigns, socket) do
    changeset = Articles.change_article(article)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def update(assigns, socket) do
    changeset = Articles.change_article(%Articles.Article{})

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end
end
