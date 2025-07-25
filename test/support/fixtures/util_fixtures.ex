defmodule Mindari.UtilFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mindari.Util` context.
  """

  @doc """
  Generate a counter.
  """
  def counter_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        name: "some name",
        value: 42
      })

    {:ok, counter} = Mindari.Util.create_counter(scope, attrs)
    counter
  end
end
