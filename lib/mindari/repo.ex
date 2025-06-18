defmodule Mindari.Repo do
  use Ecto.Repo,
    otp_app: :mindari,
    adapter: Ecto.Adapters.Postgres
end
