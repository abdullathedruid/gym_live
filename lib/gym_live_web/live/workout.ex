defmodule GymLiveWeb.GymLive.Workout do
  alias GymLive.Training
  alias GymLive.Utils.Time
  use GymLiveWeb, :live_view

  defp workout_duration(nil), do: 0

  defp workout_duration(workout) do
    Timex.now("UTC")
    |> Timex.to_naive_datetime()
    |> Timex.diff(workout.inserted_at, :seconds)
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    workout =
      Training.get_active_workout_for_user(socket.assigns.current_user)

    socket =
      assign(socket, :workout, workout)
      |> assign(:seconds, workout_duration(workout))
      |> assign_async(:completed_workouts, fn ->
        {:ok,
         %{
           completed_workouts:
             GymLive.Training.list_completed_workouts_for_user(socket.assigns.current_user)
         }}
      end)

    {:ok, socket}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:noreply, assign(socket, :seconds, socket.assigns.seconds + 1)}
  end

  @impl true
  def handle_event("start_workout", _value, socket) do
    {:ok, workout} =
      Training.create_workout(socket.assigns.current_user, %{title: generate_workout_name()})

    {:noreply, assign(socket, :workout, workout) |> assign(:seconds, 0)}
  end

  @impl true
  def handle_event("save_workout", _value, socket) do
    Training.update_workout(socket.assigns.workout, %{status: :completed})
    {:noreply, assign(socket, :workout, nil) |> assign(:seconds, 0)}
  end

  @impl true
  def handle_event("abandon_workout", _value, socket) do
    Training.delete_workout(socket.assigns.workout)

    {:noreply, assign(socket, :workout, nil) |> assign(:seconds, 0)}
  end

  def generate_workout_name do
    # todo: consider user locale
    Timex.now()
    |> Timex.format!("{WDshort} {AM} Workout")
  end
end
