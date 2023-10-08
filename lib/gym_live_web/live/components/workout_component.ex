defmodule GymLiveWeb.WorkoutComponent do
  use GymLiveWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div class="mx-auto max-w-7xl px-4 ">
        <div id={"#{@workout.id}-items"} class="grid grid-cols-1 gap-2" phx-update="stream">
          <div :for={{id, form} <- @streams.items} id={id}>
            <.simple_form
              for={form}
              phx-change="validate"
              phx-target={@myself}
              class="min-w-0"
              phx-value-id={form.data.id}
            >
              <div class="flex flex-row justify-evenly space-x-4 text-sm leading-6 text-zinc-900">
                <.input field={form[:exercise]} type="select" options={@valid_exercises} />
                <.input field={form[:weight]} phx-debounce="blur" />
                <.input field={form[:reps]} phx-debounce="blur" />
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

  def update(%{workout: workout}, socket) do
    set_forms = Enum.map(workout.sets, &build_set_form(&1, %{}))

    socket =
      socket
      |> assign(workout: workout)
      |> assign(
        valid_exercises: [
          "Squat",
          "Press",
          "Chins",
          "Face Pulls",
          "Dips",
          "Deadlift",
          "Bench Press",
          "Rows",
          "Curls",
          "Shrugs"
        ]
      )
      |> stream(:items, set_forms)

    {:ok, socket}
  end

  defp build_set_form(item_or_changeset, params, action \\ nil) do
    changeset =
      item_or_changeset
      |> GymLive.Training.change_set(params)
      |> Map.put(:action, action)

    to_form(changeset, id: "form-#{changeset.data.workout_id}-#{changeset.data.id}")
  end
end
