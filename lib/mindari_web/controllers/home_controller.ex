defmodule MindariWeb.HomeController do
  use MindariWeb, :controller

  def index(conn, _params) do
    conn
    |> assign(:page_title, "Home Page")
    |> render(:index)
  end
end
