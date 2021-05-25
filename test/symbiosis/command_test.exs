defmodule Symbiosis.CommandTest do
  use ExUnit.Case
  use ExUnitProperties

  doctest Symbiosis.Command

  alias Symbiosis.Command

  describe "parse/1 SET command" do
    property "when command is invalid must return an error" do
      check all cmd <- StreamData.string(:alphanumeric, min_length: 1) do
        assert {:error, :invalid_command} = Command.parse(cmd)
      end
    end

    property "when value is empty must return an error for any key" do
      check all key <- StreamData.string(:alphanumeric, min_length: 1) do
        assert {:error, :invalid_command} = Command.parse("SET #{key}")
      end
    end

    property "when key and value are valid must return an %Command{}" do
      check all key <- StreamData.string(:alphanumeric, min_length: 1),
                val <- StreamData.string(:alphanumeric, min_length: 1)
      do
        assert {:ok, %Command{operation: "SET", key: ^key, value: ^val}} =
          Command.parse("SET #{key} #{val}")
      end
    end
  end
end
