defmodule DesafioCliTest do
  use ExUnit.Case
  alias DesafioCli

  setup do
    :meck.new(File, [:passthrough])
    :meck.expect(File, :exists?, fn _ -> false end)
    :meck.expect(File, :write, fn _, _ -> :ok end)
    :meck.expect(File, :read, fn _ -> {:error, :enoent} end)
    :meck.expect(File, :mkdir_p, fn _ -> :ok end)

    on_exit(fn -> :meck.unload() end)
    :ok
  end

  test "SET command should store a key-value pair" do
    initial_db = %{}
    initial_transactions = []

    {db, transactions, response} = DesafioCli.process_command("SET key value", initial_db, initial_transactions)

    assert db == %{"key" => "value"}
    assert transactions == initial_transactions
    assert response == "FALSE value"
  end

  test "GET command should return NIL when key does not exist" do
    initial_db = %{}
    initial_transactions = []

    {_db, _transactions, response} = DesafioCli.process_command("GET key", initial_db, initial_transactions)

    assert response == "NIL"
  end

  test "GET command should return the value when key exists" do
    initial_db = %{"key" => "value"}
    initial_transactions = []

    {_db, _transactions, response} = DesafioCli.process_command("GET key", initial_db, initial_transactions)

    assert response == "value"
  end

  test "BEGIN command should start a transaction" do
    initial_db = %{}
    initial_transactions = []

    {_db, transactions, response} = DesafioCli.process_command("BEGIN", initial_db, initial_transactions)

    assert transactions == [initial_db]
    assert response == "1"
  end

  test "ROLLBACK command with no transaction should return error" do
    initial_db = %{}
    initial_transactions = []

    {_db, _transactions, response} = DesafioCli.process_command("ROLLBACK", initial_db, initial_transactions)

    assert response == "ERR \"No transaction to rollback\""
  end

  test "ROLLBACK command should revert to the previous state" do
    initial_db = %{"key" => "value"}
    previous_db = %{}
    initial_transactions = [previous_db]

    {db, _transactions, response} = DesafioCli.process_command("ROLLBACK", initial_db, initial_transactions)

    assert db == previous_db
    assert response == "0"
  end

  test "COMMIT command with no transaction should return error" do
    initial_db = %{}
    initial_transactions = []

    {_db, _transactions, response} = DesafioCli.process_command("COMMIT", initial_db, initial_transactions)

    assert response == "ERR \"No transaction to commit\""
  end

  test "parse_value should convert string integer to integer" do
    assert DesafioCli.parse_value("123") == 123
  end

  test "parse_value should convert TRUE and FALSE strings to booleans" do
    assert DesafioCli.parse_value("TRUE") == true
    assert DesafioCli.parse_value("FALSE") == false
  end

  test "parse_value should return string for non-boolean, non-integer values" do
    assert DesafioCli.parse_value("some_string") == "some_string"
  end
end
