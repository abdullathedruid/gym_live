defmodule GymLiveWeb.ViewWorkouts do
  use GymLiveWeb, :live_app
  alias GymLive.Training
  alias GymLive.Repo

  def mount(_params, _session, socket) do
    # todo/optimization: add pagination/infinite scroll
    workouts = Training.list_completed_workouts_for_user(socket.assigns.current_user)
    |> Repo.preload(:sets)  # Preload sets to avoid N+1 queries

    {:ok,
     socket
     |> assign(workouts: workouts)}
  end

  def render(assigns) do
    ~H"""
    <div :if={match?([_ | _], @workouts)} class="flex flex-col h-screen bg-gray-50">
      <div class="flex-grow min-h-screen w-full px-4 py-6">
        <div class="relative w-full rounded-lg shadow-sm bg-white">
          <%= for {month, workouts} <- Enum.group_by(@workouts, &Timex.beginning_of_month(&1.inserted_at)) |> Enum.sort(&Timex.diff(elem(&1, 0), elem(&2, 0))>0) do %>
            <div class="sticky top-0 bg-blue-600 text-white px-6 py-4 font-semibold shadow-md first:rounded-t-lg">
              <%= Timex.format!(month, "{Mfull} {YYYY}") %>
            </div>
            <div class="divide-y divide-gray-100">
              <%= for workout <- workouts do %>
                <div
                  class="flex flex-col sm:flex-row sm:place-content-between cursor-pointer hover:bg-gray-50 transition-colors duration-200 group"
                  phx-click="goto_workout"
                  phx-value-workout-id={workout.id}
                >
                  <div class="flex flex-col py-4 px-6">
                    <h3 class="font-medium text-gray-900 group-hover:text-blue-600 transition-colors duration-200">
                      <%= workout.title %>
                    </h3>
                    <p class="text-sm text-gray-500">
                      <%= Timex.format!(workout.inserted_at, "{WDfull} {D} {h24}:{m}") %>
                    </p>
                  </div>
                  <div class="flex items-center gap-6 px-6 pb-4 sm:pb-0">
                    <p class="text-sm text-gray-600">
                      <span class="font-medium text-gray-900"><%= length(workout.sets) %> exercises</span>
                      <span class="mx-2">·</span>
                      <span><%= format_duration(Timex.diff(workout.updated_at, workout.inserted_at, :duration)) %></span>
                    </p>
                    <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5 text-gray-400 group-hover:text-blue-600 transition-colors duration-200" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M7.293 14.707a1 1 0 010-1.414L10.586 10 7.293 6.707a1 1 0 011.414-1.414l4 4a1 1 0 010 1.414l-4 4a1 1 0 01-1.414 0z" clip-rule="evenodd" />
                    </svg>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
    </div>
    <div :if={@workouts == []} class="flex flex-col items-center justify-center min-h-screen bg-gray-50 px-4">
      <div class="text-center">
        <h2 class="text-2xl font-semibold text-gray-900 mb-2">No Workouts Yet</h2>
        <p class="text-gray-600 mb-6">Start tracking your fitness journey today!</p>
        <.link patch={~p"/edit_workout"} class="inline-flex items-center px-4 py-2 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500">
          Create Your First Workout
        </.link>
      </div>
    </div>
    """
  end

  defp format_duration(duration) do
    total_minutes = Timex.Duration.to_minutes(duration, :minutes)
    hours = div(trunc(total_minutes), 60)
    minutes = rem(trunc(total_minutes), 60)

    cond do
      hours > 0 -> "#{hours}h #{minutes}m"
      minutes > 0 -> "#{minutes}m"
      true -> "< 1m"
    end
  end

  def handle_event("goto_workout", %{"workout-id" => workout_id}, socket) do
    {:noreply, push_navigate(socket, to: ~p"/workout/#{workout_id}")}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
