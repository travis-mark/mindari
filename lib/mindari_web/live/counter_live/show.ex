defmodule MindariWeb.CounterLive.Show do
  use MindariWeb, :live_view

  alias Mindari.Util

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Counter {@counter.id}
        <:subtitle>This is a counter record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/counter"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/counter/#{@counter}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit counter
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@counter.name}</:item>
        <:item title="Value">{@counter.value}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Util.subscribe_counter(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Counter")
     |> assign(:counter, Util.get_counter!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Mindari.Util.Counter{id: id} = counter},
        %{assigns: %{counter: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :counter, counter)}
  end

  def handle_info(
        {:deleted, %Mindari.Util.Counter{id: id}},
        %{assigns: %{counter: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current counter was deleted.")
     |> push_navigate(to: ~p"/counter")}
  end

  def handle_info({type, %Mindari.Util.Counter{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end
