defmodule GymLiveWeb.GymLive.WorkoutView do
  use GymLiveWeb, :live_view

  @impl true
  def mount(%{"id" => workout_id}, _session, socket) do
    workout = GymLive.Training.get_workout!(workout_id)
    sets = GymLive.Training.list_sets_for_workout(workout)

    socket =
      assign(socket, :workout, workout)
      |> assign(:sets, sets)

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header><%= @workout.title %></.header>
      <h2><%= @workout.inserted_at %></h2>
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
