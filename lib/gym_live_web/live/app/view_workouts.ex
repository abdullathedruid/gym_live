defmodule GymLiveWeb.ViewWorkouts do
  alias GymLive.Training
  use GymLiveWeb, :live_view

  def mount(_params, _session, socket) do
    workouts = Training.list_completed_workouts_for_user(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(workouts: workouts)}
  end

  def render(assigns) do
    ~H"""
    <div :if={match?([_ | _], @workouts)} class="flex flex-col h-screen">
      <div class="flex-grow overflow-auto">
        <table class="relative w-full border">
          <%= for {month, workouts} <- Enum.group_by(@workouts, &Timex.beginning_of_month(&1.inserted_at)) |> Enum.sort(&Timex.diff(elem(&1, 0), elem(&2, 0))>0) do %>
            <thead>
              <tr>
                <th class="sticky top-0 text-gray-900 bg-gray-300" colspan="2">
                  <%= Timex.format!(month, "{Mfull} {YYYY}") %>
                </th>
              </tr>
            </thead>
            <tbody class="divide-y">
              <%= for workout <- workouts do %>
                <tr>
                  <td class="py-12">
                    <%= Timex.format!(workout.inserted_at, "{WDfull} {D} {h24}:{m}") %>
                  </td>
                  <td class="py-12"><%= workout.title %></td>
                </tr>
              <% end %>
            </tbody>
          <% end %>
        </table>
      </div>
    </div>
    <div :if={@workouts == []} class="mx-3 my-3">
      <p>You have no workouts!</p>
      <.link patch={~p"/edit_workout"}>Get started</.link>
    </div>
    """
  end
end
