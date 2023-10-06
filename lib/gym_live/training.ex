defmodule GymLive.Training do
  @moduledoc """
  The Training context.
  """

  import Ecto.Query, warn: false
  alias GymLive.Repo

  alias GymLive.Training.Workout
  alias GymLive.Account.User

  @doc """
  Returns the list of workouts.

  ## Examples

      iex> list_workouts()
      [%Workout{}, ...]

  """
  def list_workouts do
    Repo.all(Workout)
  end

  @doc """
  Gets a single workout.

  Raises `Ecto.NoResultsError` if the Workout does not exist.

  ## Examples

      iex> get_workout!(123)
      %Workout{}

      iex> get_workout!(456)
      ** (Ecto.NoResultsError)

  """
  def get_workout!(id), do: Repo.get!(Workout, id)

  @doc """
  Creates a workout.

  ## Examples

      iex> create_workout(user, %{field: value})
      {:ok, %Workout{}}

      iex> create_workout(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_workout(user, attrs \\ %{}) do
    %Workout{}
    |> Workout.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a workout.

  ## Examples

      iex> update_workout(workout, %{field: new_value})
      {:ok, %Workout{}}

      iex> update_workout(workout, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_workout(%Workout{} = workout, attrs) do
    workout
    |> Workout.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a workout.

  ## Examples

      iex> delete_workout(workout)
      {:ok, %Workout{}}

      iex> delete_workout(workout)
      {:error, %Ecto.Changeset{}}

  """
  def delete_workout(%Workout{} = workout) do
    Repo.delete(workout)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking workout changes.

  ## Examples

      iex> change_workout(workout)
      %Ecto.Changeset{data: %Workout{}}

  """
  def change_workout(%Workout{} = workout, attrs \\ %{}) do
    Workout.changeset(workout, attrs)
  end

  @spec active_workout_for_user(User.t()) :: Workout.t() | nil
  def active_workout_for_user(%User{} = user) do
    from(w in Workout,
      where: w.user_id == ^user.id and w.status == :started,
      order_by: [desc: w.updated_at],
      limit: 1,
      select: w
    )
    |> Repo.one()
  end
end
