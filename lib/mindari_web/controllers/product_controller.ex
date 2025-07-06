defmodule MindariWeb.ProductController do
  use MindariWeb, :controller

  alias Mindari.Inventory
  alias Mindari.Inventory.Product

  def index(conn, _params) do
    products = Inventory.list_products(conn.assigns.current_scope)
    render(conn, :index, products: products)
  end

  def new(conn, _params) do
    changeset =
      Inventory.change_product(conn.assigns.current_scope, %Product{
        user_id: conn.assigns.current_scope.user.id
      })

    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"product" => product_params}) do
    case Inventory.create_product(conn.assigns.current_scope, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product created successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    product = Inventory.get_product!(conn.assigns.current_scope, id)
    render(conn, :show, product: product)
  end

  def edit(conn, %{"id" => id}) do
    product = Inventory.get_product!(conn.assigns.current_scope, id)
    changeset = Inventory.change_product(conn.assigns.current_scope, product)
    render(conn, :edit, product: product, changeset: changeset)
  end

  def update(conn, %{"id" => id, "product" => product_params}) do
    product = Inventory.get_product!(conn.assigns.current_scope, id)

    case Inventory.update_product(conn.assigns.current_scope, product, product_params) do
      {:ok, product} ->
        conn
        |> put_flash(:info, "Product updated successfully.")
        |> redirect(to: ~p"/products/#{product}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, product: product, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    product = Inventory.get_product!(conn.assigns.current_scope, id)
    {:ok, _product} = Inventory.delete_product(conn.assigns.current_scope, product)

    conn
    |> put_flash(:info, "Product deleted successfully.")
    |> redirect(to: ~p"/products")
  end
end
