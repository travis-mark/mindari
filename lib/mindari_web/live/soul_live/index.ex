defmodule MindariWeb.SoulLive.Index do
  use MindariWeb, :live_view

  alias Mindari.Util

  @impl true
  def render(assigns) do
    ~H"""
    <h1>Example</h1>
    <form phx-submit="sum_function">
      <input
        type="text"
        value={@value}
        name="value"
        placeholder="n"
      />
      <input
        type="submit"
        value="Sum"
      />
    </form>
    <div :if={@results != []}>
      <h3>Results:</h3>
      <ul>
        <li :for={[n, result] <- @results}>∑(1 .. <%= n %>) = <%= result %></li>
      </ul>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Util.subscribe_counter(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Summation")
     |> assign(:value, "")
     |> assign(:results, [[2, 3]])}
  end

  @impl true
  def handle_event("sum_function", %{"value" => value}, socket) do
    result = try do
      value = value |> String.to_integer()
      Enum.sum(1..value)
    rescue
      _ -> :error
    end
    results = [[value, result] | socket.assigns.results] |> IO.inspect()

    {:noreply,
      socket
      |> assign(:results, results)
      |> assign(:value, "")}
  end
end
