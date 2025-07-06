defmodule Mindari.InventoryTest do
  use Mindari.DataCase

  alias Mindari.Inventory

  describe "products" do
    alias Mindari.Inventory.Product

    import Mindari.AccountsFixtures, only: [user_scope_fixture: 0]
    import Mindari.InventoryFixtures

    @invalid_attrs %{name: nil, category: nil, interval: nil, interval_units: nil, notes: nil}

    test "list_products/1 returns all scoped products" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      other_product = product_fixture(other_scope)
      assert Inventory.list_products(scope) == [product]
      assert Inventory.list_products(other_scope) == [other_product]
    end

    test "get_product!/2 returns the product with given id" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      other_scope = user_scope_fixture()
      assert Inventory.get_product!(scope, product.id) == product
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_product!(other_scope, product.id) end
    end

    test "create_product/2 with valid data creates a product" do
      valid_attrs = %{name: "some name", category: "some category", interval: 42, interval_units: "some interval_units", notes: "some notes"}
      scope = user_scope_fixture()

      assert {:ok, %Product{} = product} = Inventory.create_product(scope, valid_attrs)
      assert product.name == "some name"
      assert product.category == "some category"
      assert product.interval == 42
      assert product.interval_units == "some interval_units"
      assert product.notes == "some notes"
      assert product.user_id == scope.user.id
    end

    test "create_product/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.create_product(scope, @invalid_attrs)
    end

    test "update_product/3 with valid data updates the product" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      update_attrs = %{name: "some updated name", category: "some updated category", interval: 43, interval_units: "some updated interval_units", notes: "some updated notes"}

      assert {:ok, %Product{} = product} = Inventory.update_product(scope, product, update_attrs)
      assert product.name == "some updated name"
      assert product.category == "some updated category"
      assert product.interval == 43
      assert product.interval_units == "some updated interval_units"
      assert product.notes == "some updated notes"
    end

    test "update_product/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)

      assert_raise MatchError, fn ->
        Inventory.update_product(other_scope, product, %{})
      end
    end

    test "update_product/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Inventory.update_product(scope, product, @invalid_attrs)
      assert product == Inventory.get_product!(scope, product.id)
    end

    test "delete_product/2 deletes the product" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert {:ok, %Product{}} = Inventory.delete_product(scope, product)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_product!(scope, product.id) end
    end

    test "delete_product/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      product = product_fixture(scope)
      assert_raise MatchError, fn -> Inventory.delete_product(other_scope, product) end
    end

    test "change_product/2 returns a product changeset" do
      scope = user_scope_fixture()
      product = product_fixture(scope)
      assert %Ecto.Changeset{} = Inventory.change_product(scope, product)
    end
  end
end
