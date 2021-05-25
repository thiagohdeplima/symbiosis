defmodule Symbiosis.CommandTest do
  use ExUnit.Case
  use ExUnitProperties

  doctest Symbiosis.Command

  alias Symbiosis.Command

  describe "parse/1" do
    test "when command is invalid should return error" do
      assert {:error, :invalid_command} =
        Command.parse("INVALID COMMAND")
    end

    property "must return %Command{} when key and value are valid" do
      check all key <- StreamData.string(:alphanumeric, min_length: 1),
                val <- StreamData.string(:alphanumeric, min_length: 1)
      do
        assert {:ok, %Command{operation: "SET", key: key, value: val}} =
          Command.parse("SET #{key} #{val}")
      end
    end
  end
end
