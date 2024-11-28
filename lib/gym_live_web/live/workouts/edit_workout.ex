defmodule GymLiveWeb.Live.Workouts.EditWorkout do
  use GymLiveWeb, :live_app
  alias GymLive.Training
  alias GymLive.Training.{Exercises, Set, Workout}
  alias GymLive.Utils.Time

  def mount(_params, _session, socket) do
    if connected?(socket), do: :timer.send_interval(1000, self(), :tick)

    workout =
      Training.get_active_workout_for_user(socket.assigns.current_user)
      |> case do
        nil ->
          {:ok, workout} =
            Training.create_workout(socket.assigns.current_user, %{
              title: Workout.generate_workout_name()
            })

          workout

        %Workout{} = workout ->
          workout
      end

    socket =
      assign(socket, :workout, workout)
      |> assign(:seconds, workout_duration(workout))
      |> assign(form: to_form(Training.change_set(%Set{})))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div :if={@workout} class="flex flex-col h-screen">
      <.modal id="cancel-modal">
        <p>
          Are you sure you want to abandon your workout? Your workout data will be lost.
        </p>
        <div class="sm:flex sm:flex-row-reverse bg-gray-50 px-4 py-3 sm:px-6">
          <button
            phx-click="abandon_workout"
            class="inline-flex w-full justify-center rounded-md bg-red-600 px-3 py-2 text-sm font-semibold text-white shadow-sm hover:bg-red-500 sm:ml-3 sm:w-auto"
          >
            Abandon workout
          </button>
          <button
            phx-click={hide_modal("cancel-modal")}
            class="mt-3 inline-flex w-full justify-center rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50 sm:mt-0 sm:w-auto"
          >
            Cancel
          </button>
        </div>
      </.modal>

      <div class="sticky top-0 bg-blue-600 text-white px-6 py-4 font-semibold shadow-md">
        <div class="flex justify-between items-center">
          <div>
            <h1 class="text-xl font-bold"><%= @workout.title %></h1>
            <p class="text-sm text-blue-100"><%= Time.format_time(@seconds) %></p>
          </div>
          <button
            phx-click="save_workout"
            class="px-4 py-2 bg-green-500/90 hover:bg-green-500 text-white rounded-md transition duration-150 ease-in-out text-sm font-medium shadow-sm"
          >
            Finish Workout
          </button>
        </div>
      </div>

      <div class="flex-grow min-h-screen w-full pb-24">
        <div class="relative w-full bg-white">
          <.sets_table :if={length(@workout.sets) > 0} workout={@workout} />
          <.set_form form={@form} />
          <div class="px-6 py-4">
            <button
              phx-click={show_modal("cancel-modal")}
              class="max-w-xs mx-auto flex justify-center py-2 px-4 bg-red-500/90 hover:bg-red-500 text-white rounded-md transition duration-150 ease-in-out text-sm font-medium shadow-sm"
            >
              Abandon workout
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def sets_table(assigns) do
    ~H"""
    <div class="overflow-x-auto">
      <table class="w-full text-sm text-left">
        <thead class="text-xs uppercase bg-gray-100">
          <tr>
            <th scope="col" class="px-6 py-3 font-medium text-gray-500">Exercise</th>
            <th scope="col" class="px-6 py-3 font-medium text-gray-500">Weight</th>
            <th scope="col" class="px-6 py-3 font-medium text-gray-500">Reps</th>
            <th scope="col" class="px-6 py-3 font-medium text-gray-500">Action</th>
          </tr>
        </thead>
        <tbody id="sets" class="divide-y divide-gray-100">
          <tr :for={set <- @workout.sets} class="hover:bg-gray-50">
            <td class="px-6 py-4 text-gray-900"><%= Exercises.get_exercise_name(set.exercise) %></td>
            <td class="px-6 py-4 text-gray-900"><%= set.weight %></td>
            <td class="px-6 py-4 text-gray-900"><%= set.reps %></td>
            <td class="px-6 py-4">
              <button
                phx-click="remove_set"
                phx-value-set-id={set.id}
                class="text-red-500/90 hover:text-red-500 transition duration-150 ease-in-out"
              >
                <.icon name="hero-x-mark" class="h-5 w-5" />
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end

  def set_form(assigns) do
    ~H"""
    <div class="p-6 border-t border-gray-100">
      <.simple_form for={@form} phx-change="validate" phx-submit="save_set">
        <div class="space-y-6">
          <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
            <div class="sm:col-span-1">
              <label class="block text-sm font-medium text-gray-700 mb-1">Exercise</label>
              <.input
                field={@form[:exercise]}
                type="select"
                options={
                  Training.Exercises.valid_exercises_map()
                  |> Enum.map(fn {id, name} -> {name, id} end)
                }
              />
            </div>
            <div class="sm:col-span-1">
              <label class="block text-sm font-medium text-gray-700 mb-1">Weight (kg)</label>
              <.input field={@form[:weight]} type="number" class="w-full" />
            </div>
            <div class="sm:col-span-1">
              <label class="block text-sm font-medium text-gray-700 mb-1">Reps</label>
              <.input field={@form[:reps]} type="number" class="w-full" />
            </div>
          </div>
          <button
            class="max-w-xs mx-auto flex justify-center py-2 px-4 bg-blue-500/90 hover:bg-blue-500 text-white rounded-md transition duration-150 ease-in-out text-sm font-medium shadow-sm"
            phx-throttle="1000"
          >
            Add set
          </button>
        </div>
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

  def handle_event("save_set", %{"set" => params}, socket) do
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

  def handle_event("remove_set", %{"set-id" => set_id}, socket) do
    Training.get_set!(set_id)
    |> Training.delete_set()
    |> case do
      {:ok, _set} ->
        new_workout =
          socket.assigns.workout
          |> Map.update(:sets, [], fn old_sets -> Enum.reject(old_sets, &(&1.id == set_id)) end)

        {:noreply, assign(socket, workout: new_workout)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("save_workout", _unsigned_params, socket) do
    Training.update_workout(socket.assigns.workout, %{status: :completed})

    {:noreply,
     socket
     |> push_navigate(to: ~p"/workout/#{socket.assigns.workout.id}")}
  end

  def handle_event("abandon_workout", _unsigned_params, socket) do
    Training.delete_workout(socket.assigns.workout)

    {:noreply,
     socket
     |> push_navigate(to: ~p"/workouts")}
  end

  def handle_info(:tick, socket) do
    {:noreply, assign(socket, :seconds, socket.assigns.seconds + 1)}
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end

  defp workout_duration(nil), do: 0

  defp workout_duration(workout) do
    Timex.now("UTC")
    |> Timex.to_naive_datetime()
    |> Timex.diff(workout.inserted_at, :seconds)
  end
end
