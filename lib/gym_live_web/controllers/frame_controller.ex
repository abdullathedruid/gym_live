defmodule GymLiveWeb.FrameController do
  use GymLiveWeb, :controller

  alias GymLive.Training

  defmodule Colours do
    # https://codepen.io/baublet/pen/PzjmpL
    defstruct traps: "#262626",
              lats: "#404040",
              triceps: "#333",
              forearms: "#595959",
              glutes: "#1a1a1a",
              hamstrings: "#333",
              calves: "#4d4d4d",
              delts: "#333",
              biceps: "#404040",
              pecs: "#595959",
              obliques: "#262626",
              abs: "#595959",
              quads: "#333",
              adductors: "#494949"
  end

  def last_workout(conn, %{"userid" => userid}) do
    # Get the last workout for display
    image =
      case Training.get_latest_workout_for(userid) do
        nil ->
          ""

        workout ->
          GymLiveWeb.Endpoint.url() <> "/workouts/#{workout.id}/image"
      end

    conn
    |> put_resp_content_type("text/html")
    |> render("last_workout.html",
      image: image,
      host: GymLiveWeb.Endpoint.url()
    )
  end
end
