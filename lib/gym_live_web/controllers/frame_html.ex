defmodule GymLiveWeb.FrameHTML do
  use GymLiveWeb, :html

  embed_templates "frame_html/*"

  def relative_path(path) do
    "https://b291-2a02-6b6f-ea54-9900-895a-e62e-9f84-d485.ngrok-free.app#{path}"
  end
end
