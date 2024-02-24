defmodule GymLiveWeb.EditWorkout do
  alias GymLive.Training
  alias GymLive.Training.Set
  use GymLiveWeb, :live_view

  def mount(_params, _session, socket) do
    workout =
      Training.get_active_workout_for_user(socket.assigns.current_user)

    socket =
      assign(socket, :workout, workout)
      |> assign(form: to_form(Training.change_set(%Set{})))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div :if={@workout}>
      <p class="text-3xl mx-4 mt-6"><%= @workout.title %></p>
      <p class="mx-2">Workout description</p>
      <br />
      <div class="mx-6 relative overflow-x-auto shadow-md rounded-lg">
        <.sets_table workout={@workout} />
      </div>
      <.set_form form={@form} />
    </div>
    """
  end

  def sets_table(assigns) do
    ~H"""
    <table class="w-full text-sm text-left">
      <thead class="text-xs uppercase">
        <tr class="bg-gray-300">
          <th scope="col" class="px-6 py-3">Exercise</th>
          <th scope="col" class="px-6 py-3">Weight (kg)</th>
          <th scope="col" class="px-6 py-3">Reps</th>
        </tr>
      </thead>
      <tbody id="sets">
        <tr :for={set <- @workout.sets} class="even:bg-gray-100 odd:bg-gray-50">
          <td class="px-6 py-3"><%= set.exercise %></td>
          <td class="px-6 py-3"><%= set.weight %></td>
          <td class="px-6 py-3"><%= set.reps %></td>
        </tr>
      </tbody>
    </table>
    """
  end

  def set_form(assigns) do
    ~H"""
    <div class="rounded-lg bg-gray-300 mt-2 py-2 px-3">
      <p>Add new exercise:</p>
      <.simple_form for={@form} phx-change="validate" phx-submit="save">
        <div class="flex flex-row gap-8">
          <div class="flex flex-col items-center">
            <p>Exercise</p>
            <.input
              field={@form[:exercise]}
              type="select"
              options={Training.Exercises.valid_exercises()}
            />
          </div>
          <div class="flex flex-col items-center">
            <p>Weight (kg)</p>
            <.input field={@form[:weight]} type="number" />
          </div>
          <div class="flex flex-col items-center">
            <p>Reps</p>
            <.input field={@form[:reps]} type="number" />
          </div>
        </div>
        <button class="mx-auto block bg-green-400 rounded-lg px-4 py-2">Add exercise</button>
      </.simple_form>
    </div>
    """
  end

  def handle_event("validate", %{"set" => params}, socket) do
    form =
      %Set{}
      |> Training.change_set(params)
      |> Map.put(:action, :insert)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"set" => params}, socket) do
    case Training.create_set(socket.assigns.workout.id, params) do
      {:ok, set} ->
        new_workout =
          socket.assigns.workout
          |> Map.update(:sets, [set], fn old_sets -> old_sets ++ [set] end)

        {:noreply, assign(socket, workout: new_workout)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end
end
