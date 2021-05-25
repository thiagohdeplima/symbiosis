defmodule Symbiosis.CommandTest do
  use ExUnit.Case
  use ExUnitProperties

  doctest Symbiosis.Command

  alias Symbiosis.Command

  describe "parse/1 when command is invalid" do
    property "must return an error" do
      check all cmd <- StreamData.string(:alphanumeric, min_length: 1) do
        assert {:error, :invalid_command} = Command.parse(cmd)
      end
    end
  end

  describe "parse/1 SET command" do
    property "when value is empty must return an error for any key" do
      check all key <- StreamData.string(:alphanumeric, min_length: 1) do
        assert {:error, :invalid_command} = Command.parse("SET #{key}")
      end
    end

    property "when key and value are valid must return an %Command{}" do
      check all key <- StreamData.string(:alphanumeric, min_length: 1),
                val <- StreamData.string(:alphanumeric, min_length: 1)
      do
        assert {:ok, %Command{operation: :set, key: ^key, value: ^val}} =
          Command.parse("SET #{key} #{val}")
      end
    end
  end

  describe "parse/1 GET command" do
    test "when key is empty must return an error" do
      assert {:error, :invalid_command} = Command.parse("GET")
      assert {:error, :invalid_command} = Command.parse("GET ")
    end

    property "when key is valid must return an %Command{}" do
      check all key <- StreamData.string(:alphanumeric, min_length: 1) do
        assert {:ok, %Command{operation: :get, key: ^key, value: :undefined}} =
          Command.parse("GET #{key}")
      end
    end
  end

  describe "parse/1 DELETE command" do
    test "when key is empty must return an error" do
      assert {:error, :invalid_command} = Command.parse("DELETE")
      assert {:error, :invalid_command} = Command.parse("DELETE ")
    end

    property "when key is valid must return an %Command{}" do
      check all key <- StreamData.string(:alphanumeric, min_length: 1) do
        assert {:ok, %Command{operation: :delete, key: ^key, value: :undefined}} =
          Command.parse("DELETE #{key}")
      end
    end
  end
end
