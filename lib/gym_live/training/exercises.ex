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
    # ollama-3
    squat: %{
      quads: Decimal.new("0.65"),
      glutes: Decimal.new("0.15"),
      hamstrings: Decimal.new("0.25"),
      abs: Decimal.new("0.1")
    },
    press: %{
      traps: Decimal.new("0.35"),
      delts: Decimal.new("0.55"),
      serratus: Decimal.new("0.15"),
      abs: Decimal.new("0.1")
    },
    chins: %{
      biceps: Decimal.new("0.25"),
      lats: Decimal.new("0.70"),
      traps: Decimal.new("0.10"),
      rhomboids: Decimal.new("0.05"),
      # adding obliques extra
      obliques: Decimal.new("0.05"),
      # adding forearms extra
      forearms: Decimal.new("0.05")
    },
    pullups: %{
      lats: Decimal.new("0.65"),
      traps: Decimal.new("0.20"),
      delts: Decimal.new("0.15"),
      rhomboids: Decimal.new("0.1"),
      # adding obliques extra
      obliques: Decimal.new("0.1"),
      # adding forearms extra
      forearms: Decimal.new("0.05")
    },
    face_pulls: %{
      traps: Decimal.new("0.85"),
      levator_scapulae: Decimal.new("0.15"),
      rhmoboids: Decimal.new("0.1"),
      # adding obliques extra
      obliques: Decimal.new("0.1")
    },
    dips: %{
      triceps: Decimal.new("0.75"),
      deltoid: Decimal.new("0.20"),
      abs: Decimal.new("0.1"),
      # adding forearms extra
      forearms: Decimal.new("0.05")
    },
    deadlift: %{
      erector: Decimal.new("0.45"),
      glutes: Decimal.new("0.3"),
      hamstrings: Decimal.new("0.2"),
      lower_back: Decimal.new("0.15"),
      quads: Decimal.new("0.1"),
      abs: Decimal.new("0.1")
    },
    bench_press: %{
      pecs: Decimal.new("0.65"),
      deltoid: Decimal.new("0.25"),
      traps: Decimal.new("0.1"),
      abs: Decimal.new("0.1")
    },
    rows: %{
      lats: Decimal.new("0.55"),
      traps: Decimal.new("0.35"),
      rhomboids: Decimal.new("0.2"),
      biceps: Decimal.new("0.1")
    },
    # brachialis as forearms
    curls: %{biceps: Decimal.new("0.75"), forearms: Decimal.new("0.25"), abs: Decimal.new("0.1")},
    incline_bench: %{
      pecs: Decimal.new("0.7"),
      deltoid: Decimal.new("0.25"),
      traps: Decimal.new("0.1"),
      abs: Decimal.new("0.1")
    },
    press_db: %{
      delts: Decimal.new("0.55"),
      traps: Decimal.new("0.35"),
      serratus: Decimal.new("0.15"),
      abs: Decimal.new("0.1")
    },
    bench_db: %{
      pecs: Decimal.new("0.65"),
      delts: Decimal.new("0.25"),
      traps: Decimal.new("0.1"),
      abs: Decimal.new("0.1")
    },
    incline_bench_db: %{
      pecs: Decimal.new("0.7"),
      delts: Decimal.new("0.25"),
      traps: Decimal.new("0.1"),
      abs: Decimal.new("0.1")
    },
    lat_pulldown: %{
      lats: Decimal.new("0.85"),
      traps: Decimal.new("0.15"),
      rhomboids: Decimal.new("0.1"),
      # adding obliques extra
      obliques: Decimal.new("0.1")
    },
    chest_fly: %{pecs: Decimal.new("0.75"), delts: Decimal.new("0.25"), abs: Decimal.new("0.1")},
    # using forearms for anconeus
    tricep_extensions: %{
      triceps: Decimal.new("0.85"),
      forearms: Decimal.new("0.15"),
      abs: Decimal.new("0.1")
    },
    shrugs: %{traps: Decimal.new("0.9"), delts: Decimal.new("0.1")}
  }

  def valid_exercises_map, do: @valid_execises

  def valid_exercises, do: Keyword.values(@valid_execises)

  def get_exercise_name(atom) when is_atom(atom), do: Keyword.get(@valid_execises, atom)

  def get_exercise_muscles(exercise), do: Map.get(@exercise_muscles, exercise, %{})

  def list_muscles, do: @muscle_groups
end
