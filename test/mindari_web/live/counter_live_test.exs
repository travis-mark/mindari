defmodule MindariWeb.CounterLiveTest do
  use MindariWeb.ConnCase

  import Phoenix.LiveViewTest
  import Mindari.UtilFixtures

  @create_attrs %{name: "some name", value: 42}
  @update_attrs %{name: "some updated name", value: 43}
  @invalid_attrs %{name: nil, value: nil}

  setup :register_and_log_in_user

  defp create_counter(%{scope: scope}) do
    counter = counter_fixture(scope)

    %{counter: counter}
  end

  describe "Index" do
    setup [:create_counter]

    test "lists all counter", %{conn: conn, counter: counter} do
      {:ok, _index_live, html} = live(conn, ~p"/counter")

      assert html =~ "Listing Counter"
      assert html =~ counter.name
    end

    test "saves new counter", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/counter")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Counter")
               |> render_click()
               |> follow_redirect(conn, ~p"/counter/new")

      assert render(form_live) =~ "New Counter"

      assert form_live
             |> form("#counter-form", counter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#counter-form", counter: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/counter")

      html = render(index_live)
      assert html =~ "Counter created successfully"
      assert html =~ "some name"
    end

    test "updates counter in listing", %{conn: conn, counter: counter} do
      {:ok, index_live, _html} = live(conn, ~p"/counter")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#counter_collection-#{counter.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/counter/#{counter}/edit")

      assert render(form_live) =~ "Edit Counter"

      assert form_live
             |> form("#counter-form", counter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#counter-form", counter: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/counter")

      html = render(index_live)
      assert html =~ "Counter updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes counter in listing", %{conn: conn, counter: counter} do
      {:ok, index_live, _html} = live(conn, ~p"/counter")

      assert index_live |> element("#counter_collection-#{counter.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#counter-#{counter.id}")
    end
  end

  describe "Show" do
    setup [:create_counter]

    test "displays counter", %{conn: conn, counter: counter} do
      {:ok, _show_live, html} = live(conn, ~p"/counter/#{counter}")

      assert html =~ "Show Counter"
      assert html =~ counter.name
    end

    test "updates counter and returns to show", %{conn: conn, counter: counter} do
      {:ok, show_live, _html} = live(conn, ~p"/counter/#{counter}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/counter/#{counter}/edit?return_to=show")

      assert render(form_live) =~ "Edit Counter"

      assert form_live
             |> form("#counter-form", counter: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#counter-form", counter: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/counter/#{counter}")

      html = render(show_live)
      assert html =~ "Counter updated successfully"
      assert html =~ "some updated name"
    end
  end
end
