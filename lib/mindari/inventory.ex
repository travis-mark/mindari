defmodule Mindari.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Mindari.Repo

  alias Mindari.Inventory.Product
  alias Mindari.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any product changes.

  The broadcasted messages match the pattern:

    * {:created, %Product{}}
    * {:updated, %Product{}}
    * {:deleted, %Product{}}

  """
  def subscribe_products(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Mindari.PubSub, "user:#{key}:products")
  end

  defp broadcast(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Mindari.PubSub, "user:#{key}:products", message)
  end

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products(scope)
      [%Product{}, ...]

  """
  def list_products(%Scope{} = scope) do
    Repo.all(from product in Product, where: product.user_id == ^scope.user.id)
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(%Scope{} = scope, id) do
    Repo.get_by!(Product, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(%Scope{} = scope, attrs) do
    with {:ok, product = %Product{}} <-
           %Product{}
           |> Product.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast(scope, {:created, product})
      {:ok, product}
    end
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Scope{} = scope, %Product{} = product, attrs) do
    true = product.user_id == scope.user.id

    with {:ok, product = %Product{}} <-
           product
           |> Product.changeset(attrs, scope)
           |> Repo.update() do
      broadcast(scope, {:updated, product})
      {:ok, product}
    end
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Scope{} = scope, %Product{} = product) do
    true = product.user_id == scope.user.id

    with {:ok, product = %Product{}} <-
           Repo.delete(product) do
      broadcast(scope, {:deleted, product})
      {:ok, product}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking product changes.

  ## Examples

      iex> change_product(product)
      %Ecto.Changeset{data: %Product{}}

  """
  def change_product(%Scope{} = scope, %Product{} = product, attrs \\ %{}) do
    true = product.user_id == scope.user.id

    Product.changeset(product, attrs, scope)
  end
end
