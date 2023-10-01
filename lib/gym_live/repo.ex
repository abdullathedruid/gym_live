defmodule GymLive.Repo do
  use Ecto.Repo,
    otp_app: :gym_live,
    adapter: Ecto.Adapters.Postgres
end
