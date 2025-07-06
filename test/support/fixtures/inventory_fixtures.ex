defmodule Mindari.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mindari.Inventory` context.
  """

  @doc """
  Generate a product.
  """
  def product_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        category: "some category",
        interval: 42,
        interval_units: "some interval_units",
        name: "some name",
        notes: "some notes"
      })

    {:ok, product} = Mindari.Inventory.create_product(scope, attrs)
    product
  end
end
