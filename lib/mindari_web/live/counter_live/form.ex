defmodule MindariWeb.CounterLive.Form do
  use MindariWeb, :live_view

  alias Mindari.Util
  alias Mindari.Util.Counter

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage counter records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="counter-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:value]} type="number" label="Value" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Counter</.button>
          <.button navigate={return_path(@current_scope, @return_to, @counter)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    counter = Util.get_counter!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Counter")
    |> assign(:counter, counter)
    |> assign(:form, to_form(Util.change_counter(socket.assigns.current_scope, counter)))
  end

  defp apply_action(socket, :new, _params) do
    counter = %Counter{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Counter")
    |> assign(:counter, counter)
    |> assign(:form, to_form(Util.change_counter(socket.assigns.current_scope, counter)))
  end

  @impl true
  def handle_event("validate", %{"counter" => counter_params}, socket) do
    changeset = Util.change_counter(socket.assigns.current_scope, socket.assigns.counter, counter_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"counter" => counter_params}, socket) do
    save_counter(socket, socket.assigns.live_action, counter_params)
  end

  defp save_counter(socket, :edit, counter_params) do
    case Util.update_counter(socket.assigns.current_scope, socket.assigns.counter, counter_params) do
      {:ok, counter} ->
        {:noreply,
         socket
         |> put_flash(:info, "Counter updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, counter)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_counter(socket, :new, counter_params) do
    case Util.create_counter(socket.assigns.current_scope, counter_params) do
      {:ok, counter} ->
        {:noreply,
         socket
         |> put_flash(:info, "Counter created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, counter)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _counter), do: ~p"/counter"
  defp return_path(_scope, "show", counter), do: ~p"/counter/#{counter}"
end
