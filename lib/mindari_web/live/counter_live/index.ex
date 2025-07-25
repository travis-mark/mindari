defmodule MindariWeb.CounterLive.Index do
  use MindariWeb, :live_view

  alias Mindari.Util

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Counter
        <:actions>
          <.button variant="primary" navigate={~p"/counter/new"}>
            <.icon name="hero-plus" /> New Counter
          </.button>
        </:actions>
      </.header>

      <.table
        id="counter"
        rows={@streams.counter_collection}
        row_click={fn {_id, counter} -> JS.navigate(~p"/counter/#{counter}") end}
      >
        <:col :let={{_id, counter}} label="Name">{counter.name}</:col>
        <:col :let={{_id, counter}} label="Value">{counter.value}</:col>
        <:action :let={{_id, counter}}>
          <div class="sr-only">
            <.link navigate={~p"/counter/#{counter}"}>Show</.link>
          </div>
          <.link navigate={~p"/counter/#{counter}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, counter}}>
          <.link
            phx-click={JS.push("delete", value: %{id: counter.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Util.subscribe_counter(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Counter")
     |> stream(:counter_collection, Util.list_counter(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    counter = Util.get_counter!(socket.assigns.current_scope, id)
    {:ok, _} = Util.delete_counter(socket.assigns.current_scope, counter)

    {:noreply, stream_delete(socket, :counter_collection, counter)}
  end

  @impl true
  def handle_info({type, %Mindari.Util.Counter{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :counter_collection, Util.list_counter(socket.assigns.current_scope), reset: true)}
  end
end
