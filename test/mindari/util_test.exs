defmodule Mindari.UtilTest do
  use Mindari.DataCase

  alias Mindari.Util

  describe "counter" do
    alias Mindari.Util.Counter

    import Mindari.AccountsFixtures, only: [user_scope_fixture: 0]
    import Mindari.UtilFixtures

    @invalid_attrs %{name: nil, value: nil}

    test "list_counter/1 returns all scoped counter" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      counter = counter_fixture(scope)
      other_counter = counter_fixture(other_scope)
      assert Util.list_counter(scope) == [counter]
      assert Util.list_counter(other_scope) == [other_counter]
    end

    test "get_counter!/2 returns the counter with given id" do
      scope = user_scope_fixture()
      counter = counter_fixture(scope)
      other_scope = user_scope_fixture()
      assert Util.get_counter!(scope, counter.id) == counter
      assert_raise Ecto.NoResultsError, fn -> Util.get_counter!(other_scope, counter.id) end
    end

    test "create_counter/2 with valid data creates a counter" do
      valid_attrs = %{name: "some name", value: 42}
      scope = user_scope_fixture()

      assert {:ok, %Counter{} = counter} = Util.create_counter(scope, valid_attrs)
      assert counter.name == "some name"
      assert counter.value == 42
      assert counter.user_id == scope.user.id
    end

    test "create_counter/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Util.create_counter(scope, @invalid_attrs)
    end

    test "update_counter/3 with valid data updates the counter" do
      scope = user_scope_fixture()
      counter = counter_fixture(scope)
      update_attrs = %{name: "some updated name", value: 43}

      assert {:ok, %Counter{} = counter} = Util.update_counter(scope, counter, update_attrs)
      assert counter.name == "some updated name"
      assert counter.value == 43
    end

    test "update_counter/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      counter = counter_fixture(scope)

      assert_raise MatchError, fn ->
        Util.update_counter(other_scope, counter, %{})
      end
    end

    test "update_counter/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      counter = counter_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Util.update_counter(scope, counter, @invalid_attrs)
      assert counter == Util.get_counter!(scope, counter.id)
    end

    test "delete_counter/2 deletes the counter" do
      scope = user_scope_fixture()
      counter = counter_fixture(scope)
      assert {:ok, %Counter{}} = Util.delete_counter(scope, counter)
      assert_raise Ecto.NoResultsError, fn -> Util.get_counter!(scope, counter.id) end
    end

    test "delete_counter/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      counter = counter_fixture(scope)
      assert_raise MatchError, fn -> Util.delete_counter(other_scope, counter) end
    end

    test "change_counter/2 returns a counter changeset" do
      scope = user_scope_fixture()
      counter = counter_fixture(scope)
      assert %Ecto.Changeset{} = Util.change_counter(scope, counter)
    end
  end
end
