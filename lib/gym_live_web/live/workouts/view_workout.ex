defmodule GymLiveWeb.Live.Workouts.ViewWorkout do
  use GymLiveWeb, :live_app
  import GymLiveWeb.StrongMan
  alias GymLive.Strength
  alias GymLive.Training.{Exercises, Set}
  alias GymLiveWeb.StrongMan

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

  defp group_by_weight(sets), do: group_by_weight(sets, [])

  defp group_by_weight([], acc), do: Enum.reverse(acc)

  defp group_by_weight([hd | tl], []) do
    group_by_weight(tl, [{hd.weight, [hd]}])
  end

  defp group_by_weight([hd | tl], [{prev_weight, prev_sets} | rest] = acc) do
    if hd.weight == prev_weight do
      group_by_weight(tl, [{hd.weight, prev_sets ++ [hd]} | rest])
    else
      group_by_weight(tl, [{hd.weight, [hd]} | acc])
    end
  end

  def render(assigns) do
    ~H"""
    <div class="mx-auto px-3 py-3">
      <.header class="text-center"><%= @workout.title %></.header>
      <p class="text-center">
        <%= Timex.format!(@workout.inserted_at, "{D} {Mfull} {YYYY} {h24}:{m}") %>
      </p>
      <br />
      <div class="flex flex-col w-full">
        <%= for {exercise, sets} <- Enum.group_by(@sets, & &1.exercise)
        |> Enum.sort_by(fn {_ex, se} -> hd(se).inserted_at end) do %>
          <div class="uppercase text-center font-bold">
            <%= Exercises.get_exercise_name(exercise) %>
          </div>
          <div
            :for={{weight, sets_per_weight} <- group_by_weight(sets)}
            class="flex flex-row gap-3 justify-center"
          >
            <div class="">
              <%= weight %>kg
            </div>
            <div class="basis-1/2 text-center">
              <%= Enum.map(sets_per_weight, & &1.reps)
              |> Enum.map_join(", ", &to_string/1) %>
            </div>
          </div>
        <% end %>
      </div>
      <div class="m-8">
        <.strong_man colours={get_colours(@sets)} />
      </div>
    </div>
    """
  end

  defp get_colours(sets) do
    struct(
      StrongMan.Colours,
      Enum.reduce(sets, %{}, fn %Set{exercise: exercise}, acc ->
        Exercises.get_exercise_muscles(exercise)
        |> Enum.reduce(
          acc,
          fn {exercise, ratio}, acc ->
            Map.update(acc, exercise, ratio, fn prev -> Decimal.add(prev, ratio) end)
          end
        )
      end)
      |> convert_ratios_to_colours()
    )
  end

  defp convert_ratios_to_colours(empty_map) when is_map(empty_map) and empty_map == %{}, do: []

  defp convert_ratios_to_colours(ratios) do
    {_exercise, denom} =
      Enum.max_by(ratios, fn {_exercise, ratio} -> ratio end)

    Enum.map(ratios, fn {k, v} ->
      {k,
       "hsl(0, #{Decimal.mult(100, v) |> Decimal.div(denom) |> Decimal.round() |> Decimal.to_integer()}%, 40%)"}
    end)
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  # deprecated
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
