defmodule SymbiosisTest do
  use ExUnit.Case
  doctest Symbiosis

  test "greets the world" do
    assert Symbiosis.hello() == :world
  end
end
