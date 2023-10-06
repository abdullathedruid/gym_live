defmodule GymLive.Repo.Migrations.CreateWorkouts do
  use Ecto.Migration

  def change do
    create table(:workouts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string
      add :status, :string
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:workouts, [:user_id])
  end
end
