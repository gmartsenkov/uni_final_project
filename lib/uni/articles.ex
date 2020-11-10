defmodule Uni.Articles do
  @moduledoc """
  The Articles context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Articles.Article

  def filter(query, "faculty", "all"), do: query

  def filter(query, "faculty", faculty_id) do
    query
    |> join(:inner, [a], authors in assoc(a, :authors))
    |> where([articles, users, authors], users.faculty_id == ^faculty_id)
  end

  def filter(query, "department", "all"), do: query

  def filter(query, "department", department_id) do
    query
    |> join(:inner, [a], authors in assoc(a, :authors))
    |> where([articles, users, authors], users.department_id == ^department_id)
  end

  def filter(query, "scopus", "all"), do: query
  def filter(query, "scopus", "true"), do: query |> where(scopus: true)
  def filter(query, "scopus", "false"), do: query |> where(scopus: false)

  def filter(query, "wofscience", "all"), do: query
  def filter(query, "wofscience", "true"), do: query |> where(wofscience: true)
  def filter(query, "wofscience", "false"), do: query |> where(wofscience: false)

  def filter(query, "type", "all"), do: query
  def filter(query, "type", type), do: query |> where(type: ^type)

  def filter(query, "start_date", date), do: query |> where([a], a.year >= ^date)
  def filter(query, "end_date", date), do: query |> where([a], a.year <= ^date)

  @doc """
  Returns the list of articles.

  ## Examples

      iex> list_articles()
      [%Article{}, ...]

  """
  def list_articles do
    Repo.all(Article) |> Repo.preload(:owner)
  end

  @doc """
  Returns a paginated list of articles for an owner.

  ## Examples

      iex> paginate_articles(owner_id, page \\ 1, page_size \\ 10)
      %Scrivener.Page{entries: [...], total_pages: 1, total_entries: 2...}

  """
  def paginate_articles(owner_id, query \\ "", page \\ 1, page_size \\ 10) do
    search(query)
    |> where(owner_id: ^owner_id)
    |> order_by(desc: :updated_at)
    |> preload(:owner)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  defp search(""), do: Article
  defp search(query), do: from(a in Article, where: ilike(a.name, ^"%#{query}%"))

  @doc """
  Gets a single article.

  Returns

  ## Examples

      iex> get_article(123)
      %Article{}

      iex> get_article!(456)
      nil

  """
  def get_article(id),
    do: Article |> Repo.get(id) |> Repo.preload(:owner) |> Repo.preload(:authors)

  @doc """
  Creates a article.

  ## Examples

      iex> create_article(%{field: value})
      {:ok, %Article{}}

      iex> create_article(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_article(attrs \\ %{}) do
    %Article{}
    |> Article.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a article.

  ## Examples

      iex> update_article(article, %{field: new_value})
      {:ok, %Article{}}

      iex> update_article(article, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_article(%Article{} = article, attrs) do
    article
    |> Article.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a article.

  ## Examples

      iex> delete_article(article)
      {:ok, %Article{}}

      iex> delete_article(article)
      {:error, %Ecto.Changeset{}}

  """
  def delete_article(%Article{} = article) do
    Repo.delete(article)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking article changes.

  ## Examples

      iex> change_article(article)
      %Ecto.Changeset{data: %Article{}}

  """
  def change_article(%Article{} = article, attrs \\ %{}) do
    Article.changeset(article, attrs)
  end
end
