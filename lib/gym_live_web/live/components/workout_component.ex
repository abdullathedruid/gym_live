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
                class="flex"
                phx-change="validate"
                phx-submit="save"
                phx-target={@myself}
                class="min-w-0 flex-1 drag-ghost:opacity-0"
                phx-valud-id={form.data.id}
              >
                <div class="flex-auto block text-sm leading-6 text-zinc-900">
                  <.input field={form[:exercise]} />
                </div>
              </div>
            </.simple_form>
          </div>
        </div>
      </div>
    </div>
    """
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
