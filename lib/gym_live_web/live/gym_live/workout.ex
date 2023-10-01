defmodule GymLiveWeb.GymLive.Workout do
  use GymLiveWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end

