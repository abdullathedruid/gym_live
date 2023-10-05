defmodule GymLiveWeb.GymLive.Workout do
  use GymLiveWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, :workout_started, false)
    {:ok, socket}
  end

  @impl true
  def handle_event("start_workout", _value, socket) do
    {:noreply, assign(socket, :workout_started, true)}
  end

  def generate_workout_name do
    Timex.now()
    |> Timex.format!("{WDshort} {AM} Workout")
  end
end
