defmodule PomodoRob.Repo do
  use Ecto.Repo,
    otp_app: :pomodo_rob,
    adapter: Ecto.Adapters.Postgres
end
