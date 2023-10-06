defmodule GymLive.Repo.Migrations.CreateSets do
  use Ecto.Migration

  def change do
    create table(:sets, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :exercise, :string
      add :reps, :integer
      add :weight, :float
      add :workout_id, references(:workouts, on_delete: :delete_all, type: :binary_id)

      timestamps()
    end

    create index(:sets, [:workout_id])
  end
end
