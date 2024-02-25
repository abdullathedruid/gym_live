defmodule GymLiveWeb.WorkoutComponent do
  alias GymLive.Strength
  alias GymLive.Training
  use GymLiveWeb, :live_component

  @default_age 30
  @default_body_weight Decimal.new(80)

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div :if={map_size(@symmetric_strength_scores) > 0} class="mx-auto px-6">
        <h2>Symmetric Strength Scores:</h2>
        <p>Body weight: <%= @body_weight %>kg. Age: <%= @age %></p>
        <div :for={{lift, score} <- @symmetric_strength_scores} id={lift}>
          <p style={"color: #{Strength.get_colour(score)}"}>
            <%= Strength.get_breakpoint(score) |> String.upcase() %> <%= lift %> <%= score %>
          </p>
        </div>
      </div>
      <div class="mx-auto max-w-7xl px-4">
        <div class="flex flex-row space-x-4 justify-between">
          <div>Exercise</div>
          <div>Weight (kg)</div>
          <div>Reps</div>
        </div>
        <div id={"#{@workout.id}-items"} class="grid grid-cols-1 gap-2" phx-update="stream">
          <div :for={{id, form} <- @streams.items} id={id} class="">
            <.simple_form
              for={form}
              phx-change="validate"
              phx-target={@myself}
              phx-value-id={form.data.id}
            >
              <div class="flex flex-row space-x-4 justify-between text-sm leading-6 text-zinc-900">
                <.input field={form[:exercise]} type="select" options={@valid_exercises} />
                <.input field={form[:weight]} phx-debounce="blur" />
                <.input field={form[:reps]} phx-debounce="blur" />
                <div class="flex items-center justify-center">
                  <button
                    type="button"
                    class="w-8 h-8 flex-none bg-gray-200 border-red-500 border-2 leading-none rounded-xl"
                    phx-click={JS.push("delete", target: @myself, value: %{id: form.data.id})}
                  >
                    <.icon name="hero-x-mark" class="bg-red-500" />
                  </button>
                </div>
              </div>
            </.simple_form>
          </div>
        </div>
        <.button
          class="mt-4"
          phx-click={JS.push("new_set", target: @myself, value: %{workout_id: @workout.id})}
        >
          Add exercise
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("new_set", %{"workout_id" => workout_id}, socket) do
    {:ok, set} =
      GymLive.Training.create_set(workout_id, %{exercise: "bench press", weight: 0, reps: 0})

    {:noreply, socket |> stream_insert(:items, build_set_form(set, %{}))}
  end

  def handle_event("validate", %{"id" => set_id, "set" => set_params}, socket) do
    {_, item_or_changeset} =
      %GymLive.Training.Set{id: set_id, workout_id: socket.assigns.workout.id}
      |> GymLive.Training.update_set(set_params)

    item_form = build_set_form(item_or_changeset, %{}, :validate)
    {:noreply, stream_insert(socket, :items, item_form)}
  end

  def handle_event("delete", %{"id" => set_id}, socket) do
    set = GymLive.Training.get_set!(set_id)
    {:ok, _} = GymLive.Training.delete_set(set)
    {:noreply, stream_delete(socket, :items, build_set_form(set, %{}))}
  end

  def update(%{workout: workout}, socket) do
    sets = Training.list_sets_for_workout(workout)
    set_forms = Enum.map(sets, &build_set_form(&1, %{}))

    socket =
      socket
      |> assign(workout: workout)
      |> assign(body_weight: @default_body_weight)
      |> assign(age: @default_age)
      |> assign(symmetric_strength_scores: calculate_scores(sets))
      |> assign(valid_exercises: Training.Exercises.valid_exercises())
      |> stream(:items, set_forms)

    {:ok, socket}
  end

  defp calculate_scores(sets, existing_scores \\ %{}) do
    Enum.reduce(sets, existing_scores, fn %GymLive.Training.Set{
                                            reps: reps,
                                            weight: weight,
                                            exercise: exercise
                                          },
                                          acc ->
      one_rep_max =
        Strength.one_rep_max(weight, reps)
        |> Strength.round_to()

      if lift = get_exercise_atom(exercise) do
        score =
          Strength.strength_score(:male, @default_age, @default_body_weight, lift, one_rep_max)

        Map.update(acc, lift, score, fn old -> Decimal.max(old, score) end)
      else
        acc
      end
    end)
  end

  # todo: we should use ecto.enum and standardise these
  defp get_exercise_atom("Squat"), do: :squat
  defp get_exercise_atom("Press"), do: :overhead_press
  defp get_exercise_atom("Deadlift"), do: :deadlift
  defp get_exercise_atom("Bench Press"), do: :bench_press
  defp get_exercise_atom(_), do: nil

  defp build_set_form(item_or_changeset, params, action \\ nil) do
    changeset =
      item_or_changeset
      |> GymLive.Training.change_set(params)
      |> Map.put(:action, action)

    to_form(changeset, id: "form-#{changeset.data.workout_id}-#{changeset.data.id}")
  end
end
