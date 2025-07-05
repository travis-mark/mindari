defmodule MindariWeb.PageController do
  use MindariWeb, :controller

  def home(conn, _params) do
    conn
    |> assign(:page_title, "Home Page")
    |> render(:home)
  end
end
