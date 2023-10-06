defmodule GymLive.Training.Set do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sets" do
    field :exercise, :string
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
