defmodule GymLiveWeb.ViewWorkout do
  use GymLiveWeb, :live_app
  alias GymLive.Strength
  alias GymLive.Training.{Exercises, Set}

  def mount(%{"id" => workout_id}, _session, socket) do
    workout = GymLive.Training.get_workout!(workout_id)
    sets = GymLive.Training.list_sets_for_workout(workout)

    socket =
      if workout.user_id == socket.assigns.current_user.id do
        assign(socket, :workout, workout)
        |> assign(:sets, sets)
      else
        redirect(socket, to: "/workouts")
      end

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto px-3 py-3">
      <.header><%= @workout.title %></.header>
      <p><%= Timex.format!(@workout.inserted_at, "{Mfull} {YYYY} {h24}:{m}") %></p>
      <br />
      <ul>
        <%= for set <- @sets do %>
          <li>
            <%= Exercises.get_exercise_name(set.exercise) %> <%= set.reps %>x<%= set.weight %>kg
          </li>
        <% end %>
      </ul>
      <br />
      <div :if={@sets}>
        <h2>Symmetric Strength Scores:</h2>
        <%= for {exercise, score} <- calculate_scores(@sets) do %>
          <p style={"color: #{Strength.get_colour(score)}"}>
            <%= Strength.get_breakpoint(score) |> String.upcase() %>
            <%= Exercises.get_exercise_name(exercise) %> <%= score %>
          </p>
        <% end %>
      </div>
    </div>
    """
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  def calculate_scores(sets) do
    Enum.reduce(sets, %{}, fn %Set{reps: reps, weight: weight, exercise: exercise}, acc ->
      if exercise in [:squat, :press, :bench_press, :deadlift] do
        one_rep_max =
          Strength.one_rep_max(weight, reps)
          |> Strength.round_to()

        score = Strength.strength_score(:male, 30, Decimal.new(80), exercise, one_rep_max)
        [{exercise, score}]

        Map.update(acc, exercise, score, fn old -> Decimal.max(old, score) end)
      else
        acc
      end
    end)
  end
end
