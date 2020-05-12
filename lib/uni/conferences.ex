defmodule Uni.Conferences do
  @moduledoc """
  The Conferences context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Conferences.Conference

  @doc """
  Returns the list of conferences.

  ## Examples

      iex> list_conferences()
      [%Conference{}, ...]

  """
  def list_conferences do
    Repo.all(Conference)
  end

  @doc """
  Returns a paginated list of conferences for an owner.

  ## Examples

      iex> paginate_conferences(owner_id, page \\ 1, page_size \\ 10)
      %Scrivener.Page{entries: [...], total_pages: 1, total_entries: 2...}

  """
  def paginate_conferences(owner_id, query \\ "", page \\ 1, page_size \\ 10) do
    search(query)
    |> where(owner_id: ^owner_id)
    |> order_by(desc: :updated_at)
    |> preload(:owner)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  defp search(""), do: Conference
  defp search(query), do: from(a in Conference, where: ilike(a.name, ^"%#{query}%"))

  @doc """
  Gets a single conference.

  Raises `Ecto.NoResultsError` if the Conference does not exist.

  ## Examples

      iex> get_conference(123)
      %Conference{}

      iex> get_conference(456)
      nil

  """
  def get_conference(id), do: Conference |> Repo.get(id) |> Repo.preload(:owner)

  @doc """
  Creates a conference.

  ## Examples

      iex> create_conference(%{field: value})
      {:ok, %Conference{}}

      iex> create_conference(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conference(attrs \\ %{}) do
    %Conference{}
    |> Conference.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a conference.

  ## Examples

      iex> update_conference(conference, %{field: new_value})
      {:ok, %Conference{}}

      iex> update_conference(conference, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conference(%Conference{} = conference, attrs) do
    conference
    |> Conference.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conference.

  ## Examples

      iex> delete_conference(conference)
      {:ok, %Conference{}}

      iex> delete_conference(conference)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conference(%Conference{} = conference) do
    Repo.delete(conference)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conference changes.

  ## Examples

      iex> change_conference(conference)
      %Ecto.Changeset{data: %Conference{}}

  """
  def change_conference(%Conference{} = conference, attrs \\ %{}) do
    Conference.changeset(conference, attrs)
  end
end
