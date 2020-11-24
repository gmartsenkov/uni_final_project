defmodule Uni.Monographs do
  @moduledoc """
  The Monographs context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Monographs.Monograph

  def filter(query, "faculty", "all"), do: query

  def filter(query, "faculty", faculty_id) do
    query
    |> join(:left, [a], owners in assoc(a, :owner))
    |> join(:left, [a], authors in assoc(a, :authors))
    |> where(
      [monographs, owners, users, authors],
      owners.faculty_id == ^faculty_id or users.faculty_id == ^faculty_id
    )
  end

  def filter(query, "query", ""), do: query
  def filter(query, "query", q) do
    where(query, [m], ilike(m.name, ^"%#{q}%"))
  end

  def filter(query, "user", id) do
    query
    |> join(:left, [a], authors in assoc(a, :authors))
    |> where([monographs, users, authors], users.id == ^id or monographs.owner_id == ^id)
  end

  def filter(query, "department", "all"), do: query

  def filter(query, "department", department_id) do
    query
    |> join(:left, [a], owners in assoc(a, :owner))
    |> join(:left, [a], authors in assoc(a, :authors))
    |> where(
      [monographs, owners, users, authors],
      owners.department_id == ^department_id or users.department_id == ^department_id
    )
  end

  def filter(query, "start_date", ""), do: query
  def filter(query, "start_date", date), do: query |> where([a], a.year >= ^date)
  def filter(query, "end_date", ""), do: query
  def filter(query, "end_date", date), do: query |> where([a], a.year <= ^date)

  def filter(query, _type, _value), do: query

  def filter(query, [{type, value} | tail]) do
    query
    |> filter(type, value)
    |> filter(tail)
  end

  def filter(query, _filters = []), do: query

  def paginate(query, page \\ 1, page_size \\ 10) do
    query
    |> distinct([m], m.id)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  def count(query), do: query |> distinct([m], m.id) |> Repo.aggregate(:count)

  def graph(query) do
    query
    |> preload(:owner)
    |> preload(:authors)
    |> distinct([m], m.id)
    |> Repo.all()
  end

  @doc """
  Returns the list of monographs.

  ## Examples

      iex> list_monographs()
      [%Monograph{}, ...]

  """
  def list_monographs do
    Repo.all(Monograph) |> Repo.preload(:owner)
  end

  @doc """
  Returns a paginated list of monographs for an owner.

  ## Examples

      iex> paginate_monographs(owner_id, page \\ 1, page_size \\ 10)
      %Scrivener.Page{entries: [...], total_pages: 1, total_entries: 2...}

  """
  def paginate_monographs(owner_id, query \\ "", page \\ 1, page_size \\ 10) do
    search(query)
    |> where(owner_id: ^owner_id)
    |> order_by(desc: :updated_at)
    |> preload(:owner)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  defp search(""), do: Monograph
  defp search(query), do: from(a in Monograph, where: ilike(a.name, ^"%#{query}%"))

  @doc """
  Gets a single monograph.

  Returns

  ## Examples

      iex> get_monograph(123)
      %Monograph{}

      iex> get_monograph(456)
      nil

  """
  def get_monograph(id),
    do: Monograph |> Repo.get(id) |> Repo.preload(:owner) |> Repo.preload(:authors)

  @doc """
  Creates a monograph.

  ## Examples

      iex> create_monograph(%{field: value})
      {:ok, %Monograph{}}

      iex> create_monograph(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_monograph(attrs \\ %{}) do
    %Monograph{}
    |> Monograph.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a monograph.

  ## Examples

      iex> update_monograph(monograph, %{field: new_value})
      {:ok, %Monograph{}}

      iex> update_monograph(monograph, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_monograph(%Monograph{} = monograph, attrs) do
    monograph
    |> Monograph.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a monograph.

  ## Examples

      iex> delete_monograph(monograph)
      {:ok, %Monograph{}}

      iex> delete_monograph(monograph)
      {:error, %Ecto.Changeset{}}

  """
  def delete_monograph(%Monograph{} = monograph) do
    Repo.delete(monograph)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking monograph changes.

  ## Examples

      iex> change_monograph(monograph)
      %Ecto.Changeset{data: %Monograph{}}

  """
  def change_monograph(%Monograph{} = monograph, attrs \\ %{}) do
    Monograph.changeset(monograph, attrs)
  end
end
