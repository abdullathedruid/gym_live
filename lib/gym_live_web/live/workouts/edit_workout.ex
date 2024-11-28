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
    <div :if={@workout} class="flex flex-col min-h-screen bg-gray-50">
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

      <div class="sticky top-0 bg-blue-600 text-white px-6 py-4 font-semibold shadow-md z-20">
        <div class="flex justify-between items-center">
          <div>
            <h1 class="text-xl font-bold"><%= @workout.title %></h1>
            <p class="text-sm text-blue-100"><%= Time.format_time(@seconds) %></p>
          </div>
        </div>
      </div>

      <div class="flex-grow pb-24">
        <div class="max-w-3xl mx-auto">
          <div class="bg-white shadow-sm rounded-lg mt-4 mx-4">
            <div class="px-4 pt-4">
              <p class="text-gray-600 text-sm">
                Add each exercise set as you complete them. Select an exercise, enter the weight and reps, then click "Add set".
              </p>
            </div>
            <.set_form form={@form} />
          </div>

          <div :if={length(@workout.sets) > 0} class="mt-6 bg-white shadow-sm rounded-lg mx-4">
            <.sets_table workout={@workout} />
          </div>
        </div>
      </div>

      <div class="fixed right-4 bottom-20 z-20 flex flex-row-reverse items-center space-x-4 space-x-reverse">
        <button
          phx-click="save_workout"
          class="flex items-center justify-center w-16 h-16 rounded-full bg-green-500 text-white shadow-lg hover:bg-green-600 transition-colors"
        >
          <.icon name="hero-check" class="w-8 h-8" />
        </button>
        <button
          phx-click={show_modal("cancel-modal")}
          class="flex items-center justify-center w-16 h-16 rounded-full bg-red-500 text-white shadow-lg hover:bg-red-600 transition-colors"
        >
          <.icon name="hero-x-mark" class="w-8 h-8" />
        </button>
      </div>
    </div>
    """
  end

  def sets_table(assigns) do
    ~H"""
    <div class="overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead class="bg-gray-50">
          <tr>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Exercise
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Weight
            </th>
            <th scope="col" class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">
              Reps
            </th>
            <th scope="col" class="relative px-6 py-3">
              <span class="sr-only">Actions</span>
            </th>
          </tr>
        </thead>
        <tbody id="sets" class="bg-white divide-y divide-gray-200">
          <tr :for={set <- @workout.sets}>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
              <%= Exercises.get_exercise_name(set.exercise) %>
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= set.weight %></td>
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%= set.reps %></td>
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
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
    <div class="p-4">
      <.simple_form for={@form} phx-change="validate" phx-submit="save_set">
        <div class="space-y-4">
          <div class="grid grid-cols-3 gap-4">
            <div class="col-span-3 sm:col-span-1">
              <.input
                field={@form[:exercise]}
                type="select"
                options={
                  Training.Exercises.valid_exercises_map()
                  |> Enum.map(fn {id, name} -> {name, id} end)
                }
                placeholder="Exercise"
              />
            </div>
            <div class="col-span-3 sm:col-span-1">
              <.input field={@form[:weight]} type="number" placeholder="Weight (kg)" />
            </div>
            <div class="col-span-3 sm:col-span-1">
              <.input field={@form[:reps]} type="number" placeholder="Reps" />
            </div>
          </div>
          <div class="flex justify-end">
            <button
              class="inline-flex justify-center py-2 px-4 bg-blue-500/90 hover:bg-blue-500 text-white rounded-md transition duration-150 ease-in-out text-sm font-medium shadow-sm"
              phx-throttle="1000"
            >
              Add set
            </button>
          </div>
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
