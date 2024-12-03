defmodule BillingCoreTest do
  use ExUnit.Case
  doctest BillingCore

  test "greets the world" do
    assert BillingCore.hello() == :world
  end
end
