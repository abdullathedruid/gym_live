defmodule GymLiveWeb.PageController do
  use GymLiveWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
