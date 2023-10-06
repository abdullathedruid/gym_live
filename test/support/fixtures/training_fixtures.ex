defmodule GymLive.TrainingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `GymLive.Training` context.
  """

  @doc """
  Generate a workout.
  """
  def workout_fixture(user, attrs \\ %{}) do
    {:ok, workout} =
      user
      |> GymLive.Training.create_workout(
        attrs
        |> Enum.into(%{
          status: :started,
          title: "some title"
        })
      )

    workout
  end
end
