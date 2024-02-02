defmodule GymLiveWeb.GymLive.WorkoutView do
  use GymLiveWeb, :live_view

  @impl true
  def mount(%{"id" => workout_id}, _session, socket) do
    workout = GymLive.Training.get_workout!(workout_id)
    sets = GymLive.Training.list_sets_for_workout(workout)

    socket =
      if workout.user_id == socket.assigns.current_user.id do
        assign(socket, :workout, workout)
        |> assign(:sets, sets)
      else
        redirect(socket, to: "/workout")
      end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.link patch={~p"/workout"} class="bg-blue-300 px-4 py-2 rounded-2xl">
        &lt Back to workouts
      </.link>
      <div class="flex py-3">
        <.header><%= @workout.title %></.header>
        <p><%= @workout.inserted_at %></p>
      </div>
      <ul>
        <%= for set <- @sets do %>
          <li>
            <%= set.exercise %> <%= set.reps %>x<%= set.weight %>kg
          </li>
        <% end %>
      </ul>
    </div>
    """
  end
end
