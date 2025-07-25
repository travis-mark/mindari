defmodule Mindari.Util.Counter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "counter" do
    field :name, :string
    field :value, :integer
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(counter, attrs, user_scope) do
    counter
    |> cast(attrs, [:name, :value])
    |> validate_required([:name, :value])
    |> put_change(:user_id, user_scope.user.id)
  end
end
