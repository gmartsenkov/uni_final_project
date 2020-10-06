defmodule Uni.Monographs do
  @moduledoc """
  The Monographs context.
  """

  import Ecto.Query, warn: false
  alias Uni.Repo

  alias Uni.Monographs.Monograph

  @doc """
  Returns the list of monographs.

  ## Examples

      iex> list_monographs()
      [%Monograph{}, ...]

  """
  def list_monographs do
    Repo.all(Monograph)
  end

  @doc """
  Gets a single monograph.

  Raises `Ecto.NoResultsError` if the Monograph does not exist.

  ## Examples

      iex> get_monograph!(123)
      %Monograph{}

      iex> get_monograph!(456)
      ** (Ecto.NoResultsError)

  """
  def get_monograph!(id), do: Repo.get!(Monograph, id)

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
