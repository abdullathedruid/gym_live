defmodule GymLiveWeb.EditWorkout do
  alias GymLive.Training.Exercises
  alias GymLive.Training
  alias GymLive.Training.{Set, Workout}
  alias GymLive.Utils.Time
  use GymLiveWeb, :live_view

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
    <div :if={@workout}>
      <div class="mx-2 my-2 flex flex-row justify-around">
        <div>
          <p class="text-3xl"><%= @workout.title %></p>
          <p class=""><%= Time.format_time(@seconds) %></p>
        </div>
        <div class="flex flex-col justify-center">
          <button class="bg-green-400 rounded-xl px-1 py-1" phx-click="save_workout">
            Finish Workout
          </button>
        </div>
      </div>
      <div class="mx-6 relative shadow-md rounded-lg overflow-x-clip">
        <.sets_table :if={length(@workout.sets) > 0} workout={@workout} />
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
          <th scope="col" class="px-4 py-3">Exercise</th>
          <th scope="col" class="px-4 py-3">Weight</th>
          <th scope="col" class="px-4 py-3">Reps</th>
          <th scope="col" class="px-4 py-3">Action</th>
        </tr>
      </thead>
      <tbody id="sets">
        <tr :for={set <- @workout.sets} class="even:bg-gray-100 odd:bg-gray-50">
          <td class="px-4 py-3"><%= Exercises.get_exercise_name(set.exercise) %></td>
          <td class="px-4 py-3"><%= set.weight %></td>
          <td class="px-4 py-3"><%= set.reps %></td>
          <td class="px-4 py-3 text-center">
            <button phx-click="remove_set" phx-value-set-id={set.id}>
              <.icon name="hero-x-mark" class="bg-red-500" />
            </button>
          </td>
        </tr>
      </tbody>
    </table>
    """
  end

  def set_form(assigns) do
    ~H"""
    <div class="rounded-lg bg-gray-300 mt-2 py-2 px-3">
      <.simple_form for={@form} phx-change="validate" phx-submit="save_set">
        <div>
          <div class="flex flex-row gap-8 justify-around">
            <div class="flex flex-col items-center ">
              <p class="whitespace-nowrap">Exercise</p>
              <.input
                field={@form[:exercise]}
                type="select"
                options={
                  Training.Exercises.valid_exercises_map()
                  |> Enum.map(fn {id, name} -> {name, id} end)
                }
              />
            </div>
            <div class="flex flex-col items-center">
              <p class="whitespace-nowrap">Weight (kg)</p>
              <.input field={@form[:weight]} type="number" />
            </div>
            <div class="flex flex-col items-center">
              <p class="whitespace-nowrap">Reps</p>
              <.input field={@form[:reps]} type="number" />
            </div>
          </div>
          <button class="mt-3 mx-auto block bg-green-400 rounded-lg px-4 py-2" phx-throttle="1000">
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
     |> push_navigate(to: ~p"/workouts?id=#{socket.assigns.workout.id}")}
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
