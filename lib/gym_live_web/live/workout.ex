defmodule GymLiveWeb.GymLive.Workout do
  use GymLiveWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    socket
    |> assign(seconds: 0)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_info(:tick, socket) do
    socket
    |> assign(seconds: socket.assigns.seconds + 1)
    |> then(&{:noreply, &1})
  end
end
