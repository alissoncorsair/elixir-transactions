defmodule DesafioCli do
  alias Jason
  @moduledoc """
  Ponto de entrada para a CLI.
  """

  defp start_db do
    Map.new()
  end

  defp converters do
    %{
      "TRUE" => true,
      "true" => true,
      "FALSE" => false,
      "false" => false
    }
  end

  defp save_state(db, transactions) do
    file_path = "db.json"
    data = %{
      db: db,
      transactions: transactions
    }

    case Jason.encode(data) do
      {:ok, json} ->
        File.write(file_path, json)
        Logger.info("State successfully saved to #{file_path}")

      {:error, reason} ->
        Logger.error("Failed to encode data to JSON: #{reason}")
    end
  end

  defp load_state_from_file do
    file_path = "db.json"
    if File.exists?(file_path) do
      case File.read(file_path) do
        {:ok, json} ->
          case Jason.decode(json) do
            {:ok, %{"db" => db, "transactions" => transactions}} ->
              {db, transactions}

            {:error, reason} ->
              Logger.error("Failed to decode JSON: #{reason}")
              {start_db(), []}
          end

        {:error, reason} ->
          Logger.error("Failed to read file: #{reason}")
          {start_db(), []}
      end
    else
      {start_db(), []}
    end
  end

  def main(_args) do
    {db, transactions} = load_state_from_file()
    loop(db, transactions)
  end

  defp loop(db, transactions) do
    IO.write("> ")
    command = IO.gets("") |> String.trim()
    {new_db, new_transactions, response} = process_command(command, db, transactions)
    IO.puts(response)
    loop(new_db, new_transactions)
  end

  def process_command("SET " <> rest, db, transactions) do
      case String.split(rest, " ", parts: 2) do
          [key, value] ->
              exists = if Map.has_key?(db, key), do: "TRUE", else: "FALSE"
              new_db = Map.put(db, key, parse_value(value))
              save_state(new_db, transactions)
              {new_db, transactions, "#{exists} #{value}"}
          _ ->
              {db, transactions, "ERR \"Invalid SET command syntax, expected: SET <key> <value>\""}
      end
  end

  def process_command("GET " <> key, db, transactions) do
    value = Map.get(db, key, "NIL")
    {db, transactions, value}
  end

  def process_command("BEGIN", db, transactions) do
    new_transactions = [db | transactions]
    new_level = length(new_transactions)
    save_state(db, new_transactions)
    {db, new_transactions, Integer.to_string(new_level)}
  end

  def process_command("ROLLBACK", _db, []) do
    {Map.new(), [], "ERR \"No transaction to rollback\""}
  end

  def process_command("ROLLBACK", _db, [prev_db | rest_transactions]) do
    save_state(prev_db, rest_transactions)
    {prev_db, rest_transactions, Integer.to_string(length(rest_transactions))}
  end

  def process_command("COMMIT", db, []) do
    {db, [], "ERR \"No transaction to commit\""}
  end

  def process_command("COMMIT", db, [_prev_db | rest_transactions]) do
    save_state(db, rest_transactions)
    {db, rest_transactions, Integer.to_string(length(rest_transactions))}
  end

  def process_command(_, db, transactions) do
    {db, transactions, "ERR \"No command\""}
  end

  def parse_value(value) do
    cond do
      String.match?(value, ~r/^\d+$/) -> String.to_integer(value)
      value in ["TRUE", "FALSE"] -> Map.get(converters(), value)
      true -> value
    end
  end
end
