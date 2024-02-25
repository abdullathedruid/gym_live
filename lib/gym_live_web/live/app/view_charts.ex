defmodule GymLiveWeb.ViewCharts do
  use GymLiveWeb, :live_app
  import GymLiveWeb.Charts
  alias GymLive.{Strength, Training}
  alias GymLive.Training.{Exercises, Set}

  def mount(_, _session, socket) do
    initial_data =
      Training.list_all_sets_for_user(socket.assigns.current_user)

    data_map =
      for {exercise, sets} when exercise in [:squat, :press, :bench_press, :deadlift] <-
            initial_data
            |> Enum.group_by(& &1.exercise) do
        Enum.group_by(sets, &Timex.beginning_of_day(&1.inserted_at))
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
        |> then(&{exercise, &1})
      end
      |> Enum.map(fn {exercise, {maxes, timestamps}} ->
        {exercise,
         {[
            %{
              name: Exercises.get_exercise_name(exercise) <> " (1RM)",
              data: maxes,
              type: "scatter"
            },
            %{name: "Trend", data: make_trendline(maxes, timestamps), type: "line"}
          ], timestamps}}
      end)

    {:ok,
     socket
     |> assign(data: data_map)}
  end

  defp make_trendline(data, categories) when length(categories) > 1 do
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

  defp make_trendline(_, _), do: []

  def render(assigns) do
    ~H"""
    <div class="mx-4 my-4">
      <div :for={exercise <- [:squat, :deadlift, :press, :bench_press]}>
        <p><%= Exercises.get_exercise_name(exercise) %> - estimated one rep max</p>
        <.line_chart
          id="squat-chart-1"
          dataset={get_dataset(@data, exercise)}
          categories={get_categories(@data, exercise)}
        />
      </div>
    </div>
    """
  end

  defp get_dataset(data, exercise), do: Keyword.get(data, exercise, {[], []}) |> elem(0)
  defp get_categories(data, exercise), do: Keyword.get(data, exercise, {[], []}) |> elem(1)

  def handle_params(_unsigned_params, _uri, socket) do
    {:noreply, socket}
  end
end
