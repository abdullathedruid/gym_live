defmodule GymLive.Training.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "workouts" do
    field :status, Ecto.Enum, values: [:started, :completed, :deleted], default: :started
    field :title, :string
    belongs_to :user, GymLive.Account.User, foreign_key: :user_id

    timestamps()
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:title, :status])
    |> validate_required([:title, :status])
  end
end
