defmodule Mindari.Repo.Migrations.CreateCounter do
  use Ecto.Migration

  def change do
    create table(:counter) do
      add :name, :string
      add :value, :integer
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:counter, [:user_id])
  end
end
