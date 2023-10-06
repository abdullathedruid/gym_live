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

      {db, fixture} = remove_unloaded(Training.list_workouts(), [workout])
      assert db == fixture
    end

    test "get_workout!/1 returns the workout with given id" do
      user = user_fixture()
      workout = workout_fixture(user)

      {db, fixture} = remove_unloaded(Training.get_workout!(workout.id), workout)
      assert db == fixture
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

      {db, fixture} = remove_unloaded(Training.get_workout!(workout.id), workout)
      assert db == fixture
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

  describe "sets" do
    alias GymLive.Training.Set

    import GymLive.TrainingFixtures
    import GymLive.AccountFixtures

    @invalid_attrs %{exercise: nil, reps: nil, weight: nil}

    test "list_sets/0 returns all sets" do
      user = user_fixture()
      workout = workout_fixture(user)
      set = set_fixture(workout)
      {db, fixture} = remove_unloaded(Training.list_sets(), [set])
      assert db == fixture
    end

    test "get_set!/1 returns the set with given id" do
      user = user_fixture()
      workout = workout_fixture(user)
      set = set_fixture(workout)

      {db, fixture} = remove_unloaded(Training.get_set!(set.id), set)

      assert db == fixture
    end

    test "create_set/1 with valid data creates a set" do
      valid_attrs = %{exercise: "some exercise", reps: 42, weight: 120.5}

      user = user_fixture()
      workout = workout_fixture(user)

      assert {:ok, %Set{} = set} = Training.create_set(workout, valid_attrs)
      assert set.exercise == "some exercise"
      assert set.reps == 42
      assert set.weight == 120.5
    end

    test "create_set/1 with invalid data returns error changeset" do
      user = user_fixture()
      workout = workout_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Training.create_set(workout, @invalid_attrs)
    end

    test "update_set/2 with valid data updates the set" do
      user = user_fixture()
      workout = workout_fixture(user)
      set = set_fixture(workout)
      update_attrs = %{exercise: "some updated exercise", reps: 43, weight: 456.7}

      assert {:ok, %Set{} = set} = Training.update_set(set, update_attrs)
      assert set.exercise == "some updated exercise"
      assert set.reps == 43
      assert set.weight == 456.7
    end

    test "update_set/2 with invalid data returns error changeset" do
      user = user_fixture()
      workout = workout_fixture(user)
      set = set_fixture(workout)
      assert {:error, %Ecto.Changeset{}} = Training.update_set(set, @invalid_attrs)

      {db, fixture} = remove_unloaded(Training.get_set!(set.id), set)
      assert db == fixture
    end

    test "delete_set/1 deletes the set" do
      user = user_fixture()
      workout = workout_fixture(user)
      set = set_fixture(workout)
      assert {:ok, %Set{}} = Training.delete_set(set)
      assert_raise Ecto.NoResultsError, fn -> Training.get_set!(set.id) end
    end

    test "change_set/1 returns a set changeset" do
      user = user_fixture()
      workout = workout_fixture(user)
      set = set_fixture(workout)
      assert %Ecto.Changeset{} = Training.change_set(set)
    end
  end
end
