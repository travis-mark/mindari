defmodule Mindari.Util do
  @moduledoc """
  The Util context.
  """

  import Ecto.Query, warn: false
  alias Mindari.Repo

  alias Mindari.Util.Counter
  alias Mindari.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any counter changes.

  The broadcasted messages match the pattern:

    * {:created, %Counter{}}
    * {:updated, %Counter{}}
    * {:deleted, %Counter{}}

  """
  def subscribe_counter(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Mindari.PubSub, "user:#{key}:counter")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Mindari.PubSub, "user:#{key}:counter", message)
  end

  @doc """
  Returns the list of counter.

  ## Examples

      iex> list_counter(scope)
      [%Counter{}, ...]

  """
  def list_counter(%Scope{} = scope) do
    Repo.all(from counter in Counter, where: counter.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single counter.

  Raises `Ecto.NoResultsError` if the Counter does not exist.

  ## Examples

      iex> get_counter!(123)
      %Counter{}

      iex> get_counter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_counter!(%Scope{} = scope, id) do
    Repo.get_by!(Counter, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a counter.

  ## Examples

      iex> create_counter(%{field: value})
      {:ok, %Counter{}}

      iex> create_counter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_counter(%Scope{} = scope, attrs) do
    with {:ok, counter = %Counter{}} <-
           %Counter{}
           |> Counter.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, counter})
      {:ok, counter}
    end
  end

  @doc """
  Updates a counter.

  ## Examples

      iex> update_counter(counter, %{field: new_value})
      {:ok, %Counter{}}

      iex> update_counter(counter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_counter(%Scope{} = scope, %Counter{} = counter, attrs) do
    true = counter.user_id == scope.user.id

    with {:ok, counter = %Counter{}} <-
           counter
           |> Counter.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, counter})
      {:ok, counter}
    end
  end

  @doc """
  Deletes a counter.

  ## Examples

      iex> delete_counter(counter)
      {:ok, %Counter{}}

      iex> delete_counter(counter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_counter(%Scope{} = scope, %Counter{} = counter) do
    true = counter.user_id == scope.user.id

    with {:ok, counter = %Counter{}} <-
           Repo.delete(counter) do
      broadcast(scope, {:deleted, counter})
      {:ok, counter}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking counter changes.

  ## Examples

      iex> change_counter(counter)
      %Ecto.Changeset{data: %Counter{}}

  """
  def change_counter(%Scope{} = scope, %Counter{} = counter, attrs \\ %{}) do
    true = counter.user_id == scope.user.id

    Counter.changeset(counter, attrs, scope)
  end
end
