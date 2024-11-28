defmodule GymLiveWeb.Nav do
  alias GymLiveWeb.{EditWorkout, ViewCharts, ViewWorkout, ViewWorkouts}
  import Phoenix.LiveView
  use Phoenix.Component

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:active_tab, :handle_params, &handle_active_tab_params/3)}
  end

  defp handle_active_tab_params(_params, _url, socket) do
    active_tab =
      case {socket.view, socket.assigns.live_action} do
        {EditWorkout, _} ->
          :edit_workout

        {ViewWorkouts, _} ->
          :view_workouts

        {ViewWorkout, _} ->
          :view_workout

        {ViewCharts, _} ->
          :view_charts

        _ ->
          nil
      end

    {:cont, assign(socket, active_tab: active_tab)}
  end
end
