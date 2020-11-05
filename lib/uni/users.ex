defmodule Uni.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Users.User

  def by_email(email) do
    User
    |> where(email: ^email)
    |> Repo.one()
  end

  def paginate(query \\ "", page \\ 1, page_size \\ 10) do
    search(query)
    |> preload(:faculty)
    |> preload(:department)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  @doc """
  Returns users matching the query(using an ILIKE query '%query%')

  ## Examples

     iex> autocomplete("Jon")
     [%User{}, ...]

  """
  def autocomplete(query) do
    Repo.all(search(query))
  end

  def search(""), do: User

  def search(query) do
    from u in User,
      where: ilike(u.name, ^"%#{query}%")
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user(id) do
    User
    |> preload(:faculty)
    |> preload(:department)
    |> Repo.get(id)
  end

  @doc """
  Gets a list of user by their id.

  ## Examples

      iex> get_users([1,2,3])
      %User{}

      iex> get_users([])
      []

  """
  def get_users(ids), do: Repo.all(from u in User, where: u.id in ^ids)

  @doc """
  Gets a single user by email.

  Returns nil if the User does not exist.

  ## Examples

      iex> get_user_by_email!("jon@snow")
      %User{}

      iex> get_user!("missing")
      nil

  """
  def get_by_email(email), do: Repo.get_by(User, email: email)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end
end
