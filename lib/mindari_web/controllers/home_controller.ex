defmodule MindariWeb.HomeController do
  use MindariWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:page_title, "Home Page")
    |> assign(:dev_routes_enabled, Application.get_env(:mindari, :dev_routes, false))
    |> render(:index)
  end
end
