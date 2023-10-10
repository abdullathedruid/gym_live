defmodule GymLiveWeb.WorkoutTest do
  use GymLiveWeb.ConnCase

  import Phoenix.LiveViewTest
  import GymLive.AccountFixtures
  import GymLive.TrainingFixtures

  describe "Page displays workouts" do
    test "redirects to login if not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/workout")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end

    test "user can start workout", %{conn: conn} do
      user = user_fixture()

      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workout")

      new_page =
        lv
        |> element("button", "Start workout!")
        |> render_click()

      assert new_page =~ "Add exercise"
      assert new_page =~ "Abandon workout"
    end

    test "displays completed workouts for user", %{conn: conn} do
      user = user_fixture()
      workout_fixture(user, %{title: "test_workout", status: :completed})

      {:ok, lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/workout")

      assert html =~ "Loading completed workouts"

      assert lv
             |> render_async() =~ "test_workout"
    end
  end
end
