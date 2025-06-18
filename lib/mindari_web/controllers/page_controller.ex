defmodule MindariWeb.PageController do
  use MindariWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
