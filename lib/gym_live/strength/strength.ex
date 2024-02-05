defmodule GymLive.Strength do
  @breakpoints [
    {125, "World class"},
    {112.5, "Elite"},
    {100, "Exceptional"},
    {87.5, "Exceptional"},
    {75, "Advanced"},
    {60, "Proficient"},
    {45, "Novice"},
    {30, "Untrained"},
    {0, "Subpar"}
  ]

  def one_rep_max(weight, 1), do: weight

  def one_rep_max(weight, reps) do
    100 * weight / (48.8 + 53.8 * :math.exp(-0.075 * reps))
  end

  def round_to(weight, nearest \\ Decimal.new(1))

  def round_to(weight, nearest) when is_float(weight) do
    Decimal.from_float(weight)
    |> round_to(nearest)
  end

  def round_to(weight, nearest) do
    weight
    |> Decimal.div(nearest)
    |> Decimal.round()
    |> Decimal.mult(nearest)
  end

  def wilks_coefficient(weight, :male) do
    do_wilks(
      weight,
      Decimal.new("-216.0475144"),
      Decimal.new("16.2606339"),
      Decimal.new("-0.002388645"),
      Decimal.new("-0.00113732"),
      Decimal.new("7.01863E-06"),
      Decimal.new("-1.291E-08")
    )
  end

  def wilks_coefficient(weight, :female) do
    do_wilks(
      weight,
      Decimal.new("594.31747775582"),
      Decimal.new("-27.23842536447"),
      Decimal.new("0.82112226871"),
      Decimal.new("-0.00930733913"),
      Decimal.new("4.731582E-05"),
      Decimal.new("-9.054E-08")
    )
  end

  defp do_wilks(x, a, b, c, d, e, f) do
    bx = Decimal.mult(b, x)
    cx2 = pow(x, 2) |> Decimal.mult(c)
    dx3 = pow(x, 3) |> Decimal.mult(d)
    ex4 = pow(x, 4) |> Decimal.mult(e)
    fx5 = pow(x, 5) |> Decimal.mult(f)

    denominator =
      Decimal.add(a, bx)
      |> Decimal.add(cx2)
      |> Decimal.add(dx3)
      |> Decimal.add(ex4)
      |> Decimal.add(fx5)

    Decimal.div(500, denominator)
  end

  @spec pow(Decimal.t(), non_neg_integer()) :: Decimal.t()
  defp pow(_x, 0), do: Decimal.new(1)
  defp pow(x, 1), do: x

  defp pow(x, n) when rem(n, 2) == 0 do
    sqrt_result = pow(x, div(n, 2))
    Decimal.mult(sqrt_result, sqrt_result)
  end

  defp pow(x, n), do: Decimal.mult(x, pow(x, n - 1))

  # _this.state.results.lifts[lift].userScore = Math.round(
  # Strength.singleLiftStrengthScore(_this.state.unitSystem, _this.state.sex, _this.state.age, _this.state.bodyweight, lf.liftName, oneRM)
  # * 10) / 10;
  def strength_score(sex, age, body_weight, lift, one_rep_max) do
    wilks_to_strength_score(
      expected_wilks(sex, body_weight, lift, one_rep_max),
      age
    )
    |> round_to(Decimal.new("0.1"))
  end

  defp wilks_to_strength_score(wilks, age) when age < 23 do
    t2 = pow(age, 2) |> Decimal.mult("0.0038961")
    t1 = Decimal.mult("0.166926", age)
    t = Decimal.sub(t2, t1) |> Decimal.add("2.80303")
    Decimal.mult(wilks, t) |> Decimal.div(4)
  end

  defp wilks_to_strength_score(wilks, age) when age > 40 do
    t2 = pow(age, 2) |> Decimal.mult("467683e-9")
    t1 = Decimal.mult("0.0299717", age)
    t = Decimal.sub(t2, t1) |> Decimal.add("1.45454")
    Decimal.mult(wilks, t) |> Decimal.div(4)
  end

  defp wilks_to_strength_score(wilks, _age) do
    Decimal.div(wilks, 4)
  end

  defp expected_wilks(sex, body_weight, lift, one_rep_max) do
    wilks(sex, body_weight, expected_pl_total(sex, body_weight, lift, one_rep_max))
  end

  defp wilks(sex, body_weight, pl_total) do
    Decimal.mult(pl_total, wilks_coefficient(body_weight, sex))
  end

  defp expected_pl_total(sex, age, lift, one_rep_max) do
    Decimal.div(one_rep_max, percent_of_pl_total(sex, age, lift, one_rep_max))
  end

  # defp percent_of_pl_total(sex, age, lift, one_rep_max)
  defp percent_of_pl_total(:male, _age, :deadlift, _one_rep_max), do: Decimal.new("0.396825")
  defp percent_of_pl_total(:female, _age, :deadlift, _one_rep_max), do: Decimal.new("0.414938")

  defp percent_of_pl_total(:male, age, :squat, one_rep_max),
    do: Decimal.mult("0.87", percent_of_pl_total(:male, age, :deadlift, one_rep_max))

  defp percent_of_pl_total(:male, age, :bench_press, one_rep_max),
    do: Decimal.mult("0.65", percent_of_pl_total(:male, age, :deadlift, one_rep_max))

  defp percent_of_pl_total(:male, age, :overhead_press, one_rep_max),
    do: Decimal.mult("0.65", percent_of_pl_total(:male, age, :bench_press, one_rep_max))

  # defp percent_of_pl_total(:male, age, :chin_up, one_rep_max) do
  #   l = Decimal.sub(one_rep_max, age)
  #   l4 = pow(l, 4) |> Decimal.mult("4.01897e-10")
  #   l3 = pow(l, 3) |> Decimal.mult("2.34536e-7")
  #   l2 = pow(l, 2) |> Decimal.mult("502252e-10")
  #   l1 = Decimal.mult(l, "0.00502633")
  #   Decimal.sub(l4, l3) |> Decimal.add(l2) |> Decimal.sub(l1) |> Decimal.add("0.459545")
  # end

  # defp percent_of_pl_total(:male, age, :pull_up, one_rep_max) do
  #   Decimal.mult("0.95", percent_of_pl_total(:male, age, :chin_up, one_rep_max))
  # end
end
