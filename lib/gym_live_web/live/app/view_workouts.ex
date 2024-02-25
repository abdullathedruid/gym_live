defmodule GymLiveWeb.ViewWorkouts do
  alias GymLive.Training
  use GymLiveWeb, :live_view

  def mount(_params, _session, socket) do
    # todo/optimization: add pagination/infinite scroll
    workouts = Training.list_completed_workouts_for_user(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(workouts: workouts)}
  end

  def render(assigns) do
    ~H"""
    <div :if={match?([_ | _], @workouts)} class="flex flex-col h-screen">
      <div class="flex-grow min-h-screen">
        <div class="relative w-full border rounded-lg">
          <%= for {month, workouts} <- Enum.group_by(@workouts, &Timex.beginning_of_month(&1.inserted_at)) |> Enum.sort(&Timex.diff(elem(&1, 0), elem(&2, 0))>0) do %>
            <div class="sticky top-0 text-gray-900 bg-gray-300 px-6 py-3">
              <%= Timex.format!(month, "{Mfull} {YYYY}") %>
            </div>
            <div class="divide-y">
              <%= for workout <- workouts do %>
                <div class="flex flex-row place-content-between">
                  <p class="py-3 px-4">
                    <%= Timex.format!(workout.inserted_at, "{WDfull} {D} {h24}:{m}") %>
                  </p>
                  <p class="py-3 px-4"><%= workout.title %></p>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    <div :if={@workouts == []} class="mx-3 my-3">
      <p>You have no workouts!</p>
      <.link patch={~p"/edit_workout"}>Get started</.link>
    </div>
    """
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
