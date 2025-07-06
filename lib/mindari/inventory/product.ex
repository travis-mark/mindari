defmodule Mindari.Inventory.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :category, :string
    field :interval, :integer
    field :interval_units, :string
    field :notes, :string
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs, user_scope) do
    product
    |> cast(attrs, [:name, :category, :interval, :interval_units, :notes])
    |> validate_required([:name, :category, :interval, :interval_units])
    |> put_change(:user_id, user_scope.user.id)
  end
end
