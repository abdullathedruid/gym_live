defmodule GymLive.Training.Workout do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]
  schema "workouts" do
    field :status, Ecto.Enum, values: [:started, :completed, :deleted], default: :started
    field :title, :string
    belongs_to :user, GymLive.Account.User, foreign_key: :user_id
    has_many :sets, GymLive.Training.Set

    timestamps()
  end

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:title, :status])
    |> validate_required([:title, :status])
  end
end
