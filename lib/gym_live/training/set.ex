defmodule GymLive.Training.Set do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]
  schema "sets" do
    field :exercise, Ecto.Enum, values: GymLive.Training.Exercises.valid_exercises_map()
    field :reps, :integer
    field :weight, :float
    belongs_to :workout, GymLive.Training.Workout, foreign_key: :workout_id

    timestamps()
  end

  @doc false
  def changeset(set, attrs) do
    set
    |> cast(attrs, [:exercise, :reps, :weight])
    |> validate_required([:exercise, :reps, :weight])
  end
end
