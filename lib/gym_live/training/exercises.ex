defmodule GymLive.Training.Exercises do
  @valid_execises [
    squat: "Squat",
    press: "Press",
    chins: "Chins",
    pullups: "Pull ups",
    face_pulls: "Face Pulls",
    dips: "Dips",
    deadlift: "Deadlift",
    bench_press: "Bench Press",
    rows: "Rows",
    curls: "Curls",
    shrugs: "Shrugs",
    incline_bench: "Incline Bench Press",
    press_db: "Press (Dumbell)",
    bench_db: "Bench Press (Dumbell)",
    incline_bench_db: "Incline Bench Press (Dumbell)",
    lat_pulldown: "Lat pulldown",
    chest_fly: "Chest fly",
    tricep_extensions: "Tricep extensions"
  ]

  @muscle_groups [
    :traps,
    :lats,
    :triceps,
    :forearms,
    :glutes,
    :hamstrings,
    :calves,
    :delts,
    :biceps,
    :pecs,
    :obliques,
    :abs,
    :quads,
    :adductors
  ]

  @exercise_muscles %{
    # https://forums.t-nation.com/t/inside-the-muscles-best-chest-and-triceps-exercises/284620
    bench_press: %{pecs: Decimal.new("0.898"), triceps: Decimal.new("0.101")},
    incline_bench: %{pecs: Decimal.new("0.905"), triceps: Decimal.new("0.094")},
    bench_db: %{pecs: Decimal.new("0.904"), triceps: Decimal.new("0.095")},
    incline_bench_db: %{pecs: Decimal.new("0.897"), triceps: Decimal.new("0.102")},
    dips: %{pecs: Decimal.new("0.815"), triceps: Decimal.new("0.185")},
    tricep_extensions: %{pecs: Decimal.new("0.423"), triceps: Decimal.new("0.576")},
    chest_fly: %{pecs: Decimal.new("0.970"), triceps: Decimal.new("0.029")},
    # https://forums.t-nation.com/t/inside-the-muscles-best-back-and-biceps-exercises/284621
    rows: %{biceps: Decimal.new("0.086"), lats: Decimal.new("0.357"), traps: Decimal.new("0.557")},
    pullups: %{
      biceps: Decimal.new("0.169"),
      lats: Decimal.new("0.334"),
      traps: Decimal.new("0.330"),
      delts: Decimal.new("0.167")
    },
    chins: %{
      biceps: Decimal.new("0.292"),
      lats: Decimal.new("0.295"),
      traps: Decimal.new("0.308"),
      delts: Decimal.new("0.106")
    },
    curls: %{
      biceps: Decimal.new("0.283"),
      lats: Decimal.new("0.113"),
      traps: Decimal.new("0.603")
    },
    press: %{traps: Decimal.new("0.270"), delts: Decimal.new("0.730")},
    press_db: %{traps: Decimal.new("0.182"), delts: Decimal.new("0.818")},
    # https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5435978/
    squat: %{quads: Decimal.new("0.833"), glutes: Decimal.new("0.167")},
    # https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7046193/#:~:text=Deadlift%20also%20showed%20greater%20activation,femoris%20within%20hamstring%20muscles%20complex.
    deadlift: %{
      quads: Decimal.new("0.207"),
      glutes: Decimal.new("0.205"),
      hamstrings: Decimal.new("0.270"),
      adductors: Decimal.new("0.318")
    }
  }

  def valid_exercises_map, do: @valid_execises

  def valid_exercises, do: Keyword.values(@valid_execises)

  def get_exercise_name(atom) when is_atom(atom), do: Keyword.get(@valid_execises, atom)

  def get_exercise_muscles(exercise), do: Map.get(@exercise_muscles, exercise, %{})

  def list_muscles, do: @muscle_groups
end
