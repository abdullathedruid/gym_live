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
    lat_pulldown: "Lat pulldown",
    chest_fly: "Chest fly",
    tricep_extensions: "Tricep extensions"
  ]
  def valid_exercises_map, do: @valid_execises

  def valid_exercises, do: Keyword.values(@valid_execises)

  def get_exercise_name(atom) when is_atom(atom), do: Keyword.get(@valid_execises, atom)
end
