defmodule GymLive.TrainingTest do
  use GymLive.DataCase

  alias GymLive.Training

  describe "workouts" do
    alias GymLive.Training.Workout

    import GymLive.TrainingFixtures
    import GymLive.AccountFixtures

    @invalid_attrs %{status: nil, title: nil}

    test "list_workouts/0 returns all workouts" do
      user = user_fixture()
      workout = workout_fixture(user)
      assert Training.list_workouts() |> Repo.preload([:user]) == [workout]
    end

    test "get_workout!/1 returns the workout with given id" do
      user = user_fixture()
      workout = workout_fixture(user)
      assert Training.get_workout!(workout.id) |> Repo.preload([:user]) == workout
    end

    test "create_workout/1 with valid data creates a workout" do
      valid_attrs = %{status: :started, title: "some title"}
      user = user_fixture()

      assert {:ok, %Workout{} = workout} = Training.create_workout(user, valid_attrs)
      assert workout.status == :started
      assert workout.title == "some title"
    end

    test "create_workout/1 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Training.create_workout(user, @invalid_attrs)
    end

    test "update_workout/2 with valid data updates the workout" do
      user = user_fixture()
      workout = workout_fixture(user)
      update_attrs = %{status: :completed, title: "some updated title"}

      assert {:ok, %Workout{} = workout} = Training.update_workout(workout, update_attrs)
      assert workout.status == :completed
      assert workout.title == "some updated title"
    end

    test "update_workout/2 with invalid data returns error changeset" do
      user = user_fixture()
      workout = workout_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Training.update_workout(workout, @invalid_attrs)
      assert workout == Training.get_workout!(workout.id) |> Repo.preload([:user])
    end

    test "delete_workout/1 deletes the workout" do
      user = user_fixture()
      workout = workout_fixture(user)
      assert {:ok, %Workout{}} = Training.delete_workout(workout)
      assert_raise Ecto.NoResultsError, fn -> Training.get_workout!(workout.id) end
    end

    test "change_workout/1 returns a workout changeset" do
      user = user_fixture()
      workout = workout_fixture(user)
      assert %Ecto.Changeset{} = Training.change_workout(workout)
    end
  end
end
