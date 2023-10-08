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

  def list_completed_workouts_for_user(%User{} = user) do
    from(w in Workout,
      where: w.user_id == ^user.id and w.status == :completed,
      order_by: [desc: w.inserted_at]
    )
    |> Repo.all()
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
    |> case do
      {:ok, workout} -> {:ok, Map.put(workout, :sets, [])}
      error -> error
    end
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

  @spec get_active_workout_for_user(User.t()) :: Workout.t() | nil
  def get_active_workout_for_user(%User{} = user) do
    from(w in Workout,
      where: w.user_id == ^user.id and w.status == :started,
      order_by: [desc: w.inserted_at],
      limit: 1,
      select: w,
      left_join: sets in assoc(w, :sets),
      preload: [:sets]
    )
    |> Repo.one()
  end

  alias GymLive.Training.Set

  @doc """
  Returns the list of sets.

  ## Examples

      iex> list_sets()
      [%Set{}, ...]

  """
  def list_sets do
    Repo.all(Set)
  end

  @doc """
  Gets a single set.

  Raises `Ecto.NoResultsError` if the Set does not exist.

  ## Examples

      iex> get_set!(123)
      %Set{}

      iex> get_set!(456)
      ** (Ecto.NoResultsError)

  """
  def get_set!(id), do: Repo.get!(Set, id)

  @doc """
  Creates a set.

  ## Examples

      iex> create_set(workout, %{field: value})
      {:ok, %Set{}}

      iex> create_set(workout, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_set(workout, attrs \\ %{})

  def create_set(%Workout{id: workout_id}, attrs) do
    %Set{workout_id: workout_id}
    |> Set.changeset(attrs)
    |> Repo.insert()
  end

  def create_set(workout_id, attrs) do
    %Set{workout_id: workout_id}
    |> Set.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a set.

  ## Examples

      iex> update_set(set, %{field: new_value})
      {:ok, %Set{}}

      iex> update_set(set, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_set(%Set{} = set, attrs) do
    set
    |> Set.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a set.

  ## Examples

      iex> delete_set(set)
      {:ok, %Set{}}

      iex> delete_set(set)
      {:error, %Ecto.Changeset{}}

  """
  def delete_set(%Set{} = set) do
    Repo.delete(set)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking set changes.

  ## Examples

      iex> change_set(set)
      %Ecto.Changeset{data: %Set{}}

  """
  def change_set(set_or_changeset, attrs \\ %{}) do
    Set.changeset(set_or_changeset, attrs)
  end
end
