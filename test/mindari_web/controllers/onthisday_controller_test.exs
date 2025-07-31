defmodule MindariWeb.OnThisDayControllerTest do
  use MindariWeb.ConnCase

  import Mindari.AccountsFixtures

  setup do
    %{unconfirmed_user: unconfirmed_user_fixture(), user: user_fixture()}
  end

  describe "On This Day" do
    test "Renders page", %{conn: conn, user: user} do
      user = set_password(user)
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })
      conn = get(conn, ~p"/then")
      html = html_response(conn, 200)

      assert html =~ "On This Day"
    end

    test "Has link to home page", %{conn: conn, user: user} do
      user = set_password(user)
      conn =
        post(conn, ~p"/login", %{
          "user" => %{"email" => user.email, "password" => valid_user_password()}
        })
      conn = get(conn, ~p"/then")
      html = html_response(conn, 200)

      assert html =~ ~r/href="\/"/
    end
  end
end
