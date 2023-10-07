defmodule GymLiveWeb.WorkoutComponent do
  use GymLiveWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="bg-gray-100 py-4 rounded-lg">
      <div class="mx-auto max-w-7xl px-4 ">
        <div id={"#{@workout_id}-items"} class="grid grid-cols-1 gap-2">
          <div :for={form <- @items} id={"list#{@workout_id}-item#{form.id}"}>
            <.simple_form for={form}>
              <div
                phx-change="validate"
                phx-submit="save"
                phx-target={@myself}
                class="min-w-0"
                phx-valud-id={form.data.id}
              >
                <div class="flex flex-row justify-evenly space-x-4 text-sm leading-6 text-zinc-900">
                  <.input field={form[:exercise]} />
                  <.input field={form[:weight]} />
                  <.input field={form[:reps]} />
                </div>
              </div>
            </.simple_form>
          </div>
          <.button
            class="mt-4"
            phx-click={JS.push("new_set", target: @myself, value: %{workout_id: @workout_id})}
          >
            Add exercise
          </.button>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("new_set", %{"workout_id" => workout_id}, socket) do
    {:ok, set} =
      GymLive.Training.get_workout!(workout_id)
      |> GymLive.Training.create_set(%{exercise: "bench press", weight: 0, reps: 0})

    {:noreply, assign(socket, :items, [build_set_form(set, %{}) | socket.assigns.items])}
  end

  def update(%{workout: workout}, socket) do
    set_forms = Enum.map(workout.sets, &build_set_form(&1, %{}))

    socket =
      socket |> assign(workout_id: workout.id, workout_title: workout.title, items: set_forms)

    {:ok, socket}
  end

  defp build_set_form(item_or_changeset, params) do
    changeset = item_or_changeset |> GymLive.Training.change_set(params)

    to_form(changeset, id: "form-#{changeset.data.workout_id}-#{changeset.data.id}")
  end
end
