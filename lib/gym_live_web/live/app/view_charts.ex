defmodule GymLiveWeb.ViewCharts do
  use GymLiveWeb, :live_app
  import GymLiveWeb.Charts
  alias GymLive.{Strength, Training}
  alias GymLive.Training.Set

  def mount(_, _session, socket) do
    data =
      Training.list_all_sets_by_exercise_for_user(socket.assigns.current_user, :squat)

    {data, categories} =
      Enum.group_by(data, &Timex.beginning_of_day(&1.inserted_at))
      |> Enum.flat_map(fn {_day, sets} ->
        Enum.max_by(sets, &Strength.one_rep_max(&1.weight, &1.reps))
        |> case do
          %Set{weight: weight, reps: reps, inserted_at: time} ->
            [
              {Strength.one_rep_max(weight, reps)
               |> Strength.round_to()
               |> Decimal.to_string(), DateTime.to_unix(time) * 1000}
            ]

          nil ->
            []
        end
      end)
      |> Enum.unzip()

    {:ok,
     socket
     |> assign(
       dataset: [
         %{name: "Squat (1RM)", data: data, type: "scatter"},
         %{name: "Trend", data: make_trendline(data, categories), type: "line"}
       ]
     )
     |> assign(categories: categories)}
  end

  defp make_trendline(data, categories) do
    x_m = (Enum.sum(categories) / length(categories)) |> trunc()
    y_m = Enum.reduce(data, 0, fn x, acc -> Decimal.add(x, acc) end) |> Decimal.div(length(data))

    m_n =
      Enum.zip(categories, data)
      |> Enum.reduce(0, fn {x, y}, acc ->
        Decimal.sub(x, x_m) |> Decimal.mult(Decimal.sub(y, y_m)) |> Decimal.add(acc)
      end)

    m_d =
      Enum.reduce(categories, 0, fn x, acc ->
        xd = Decimal.sub(x, x_m)
        Decimal.mult(xd, xd) |> Decimal.add(acc)
      end)

    m = Decimal.div(m_n, m_d)

    c = Decimal.sub(y_m, Decimal.mult(m, x_m))

    for x <- categories,
        do: Decimal.mult(m, x) |> Decimal.add(c) |> Decimal.round(1) |> Decimal.to_string()
  end

  def render(assigns) do
    ~H"""
    <div class="mx-4 my-4">
      <p>Squat - estimated one rep max</p>
      <.line_chart id="squat-chart-1" toolbar={true} dataset={@dataset} categories={@categories} />
    </div>
    """
  end

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
