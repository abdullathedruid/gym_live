defmodule GymLiveWeb.ViewCharts do
  use GymLiveWeb, :live_app
  import GymLiveWeb.Charts
  alias GymLive.{Strength, Training}
  alias GymLive.Training.Set

  def mount(_, _session, socket) do
    data =
      Training.list_all_sets_by_exercise_for_user(socket.assigns.current_user, :squat)

    {data, categories} =
      Enum.map(data, fn %Set{weight: weight, reps: reps, inserted_at: time} ->
        {Strength.one_rep_max(weight, reps) |> Strength.round_to(1) |> Decimal.to_string(),
         DateTime.to_unix(time) * 1000}
      end)
      |> Enum.unzip()

    {:ok,
     socket
     |> assign(dataset: [%{name: "Squat (1RM)", data: data}])
     |> assign(categories: categories)}
  end

  def render(assigns) do
    ~H"""
    <div class="mx-4 my-4">
      <p>Squat - estimated one rep max</p>
      <.line_chart id="squat-chart-1" dataset={@dataset} categories={@categories} />
    </div>
    """
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
