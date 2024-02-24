defmodule GymLive.Training.Exercises do
  @valid_execises [
    squat: "Squat",
    press: "Press",
    chins: "Chins",
    face_pulls: "Face Pulls",
    dips: "Dips",
    deadlift: "Deadlift",
    bench_press: "Bench Press",
    rows: "Rows",
    curls: "Curls",
    shrugs: "Shrugs"
  ]
  def valid_exercises_map, do: @valid_execises

  def valid_exercises, do: Keyword.values(@valid_execises)
end
