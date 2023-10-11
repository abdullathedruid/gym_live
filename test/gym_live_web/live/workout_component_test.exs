defmodule GymLiveWeb.WorkoutComponentTest do
  use GymLiveWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import LiveComponentTests
  import GymLive.AccountFixtures
  import GymLive.TrainingFixtures

  setup %{conn: conn} do
    user = user_fixture()
    workout = workout_fixture(user)

    {:ok, lv, _html} =
      live_component_isolated(conn, GymLiveWeb.WorkoutComponent, workout: workout)

    {:ok, user: user, workout: workout, lv: lv}
  end

  describe "Adding sets" do
    test "can add set", %{lv: lv, workout: workout} do
      button = element(lv, "button", "Add exercise")
      render_click(button)
      [_] = GymLive.Training.list_sets_for_workout(workout)
    end

    test "can delete set", %{lv: lv, workout: workout} do
      add_set_button = element(lv, "button", "Add exercise")
      render_click(add_set_button)
      [_] = GymLive.Training.list_sets_for_workout(workout)

      remove_set_button =
        element(lv, ~s{button[phx-click*="delete"]})

      render_click(remove_set_button)
      [] = GymLive.Training.list_sets_for_workout(workout)
    end
  end
end
