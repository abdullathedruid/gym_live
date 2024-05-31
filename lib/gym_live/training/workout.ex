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

  @type t :: %__MODULE__{
          status: :started | :completed | :deleted,
          title: String.t(),
          user_id: String.t(),
          user: GymLive.Account.User.t(),
          sets: [GymLive.Training.Set.t()]
        }

  @doc false
  def changeset(workout, attrs) do
    workout
    |> cast(attrs, [:title, :status])
    |> validate_required([:title, :status])
  end

  def generate_workout_name do
    # todo: consider user locale
    Timex.now()
    |> Timex.format!("{WDshort} {AM} Workout")
  end
end
