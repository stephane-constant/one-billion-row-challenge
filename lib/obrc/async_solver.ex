defmodule OneBillionRowChallenge.AsyncSolver do
  alias OneBillionRowChallenge.{Coordinator, Worker}

  @moduledoc """
  Documentation for `OneBillionRowChallenge.AsyncSolver`.
  """

  @doc """
  Reads the input file, parses the city name and the temperature, groups them by city,
  launches series of asynchronous workers (one per city) and the results coordinator,
  in order to compute and display the min / mean / max temperature per city.

  ## Examples

      iex> OneBillionRowChallenge.AsyncSolver.run("data/measurements_small.txt")
      # Delhi=28.6/30.0/31.0
      # Guangzhou=23.1/23.0/23.0
      # Jakarta=-6.2/-6.0/-6.0
      # Manila=14.6/15.0/15.0
      # Mexico City=19.4/19.0/19.0
      # Seoul=37.6/38.0/38.0
      # São Paulo=-23.6/-24.0/-24.0
      # Tokyo=19.1/27.0/36.0

  """
  def run(puzzle_filename) do
    with start_time <- Time.utc_now(),
         temperatures_by_city <-
           File.stream!(puzzle_filename, [:read])
           |> Enum.map(&String.trim/1)
           |> Enum.map(&String.split(&1, ";"))
           |> Enum.map(fn [city | temperature] -> %{city: city, temp: Enum.at(temperature, 0)} end)
           |> Enum.group_by(&(&1.city), &(&1.temp)),
#         _ <- IO.inspect(temperatures_by_city),
         coordinator_pid = spawn(Coordinator, :loop, [self(), [], Enum.count(Map.keys(temperatures_by_city))])
      do

      temperatures_by_city
      |> Enum.each(fn city_and_temperatures ->
        worker_pid = spawn(Worker, :loop, [])
        send(worker_pid, {coordinator_pid, city_and_temperatures})
      end)

      receive do
        {:ok, city_statistics} ->
          finish_time = Time.utc_now()

          city_statistics
          |> Enum.each(fn x -> IO.puts("#{x.city}=#{x.min}/#{x.mean}/#{x.max}") end)

          duration_in_ms = Time.diff(finish_time, start_time, :millisecond)
          IO.puts("It took #{duration_in_ms} milliseconds to process the file (before display of results).")
      end
    end
  end
end

defmodule OneBillionRowChallenge.Coordinator do

  def loop(parent_pid, results \\ [], expected_results_count) do
    receive do
      {:ok, result} ->
        new_results = [result | results]

        if expected_results_count == Enum.count(new_results) do
          send(self(), :exit)
        end

        # Recursion
        loop(parent_pid, new_results, expected_results_count)

      :exit ->
        send(parent_pid, {:ok, results})

      # Recursion for any other message kind
      _ ->
        loop(parent_pid, results, expected_results_count)
    end
  end
end

defmodule OneBillionRowChallenge.Worker do

  def loop do
    receive do
      {sender_pid, {city, temperatures}} ->
#        IO.inspect({city, temperatures})
        values = temperatures |> Enum.map(&String.to_float/1)

        send(sender_pid,
          {:ok,
            %{city: city,
              min: Float.round(Enum.min(values), 1),
              max: Float.round(Enum.max(values), 1),
              mean: Float.round(Enum.sum(values) / Enum.count(values), 1)
            }
          })

      _ ->
        IO.puts("Don't know how to process this message")
    end

    # Recursion
    loop()
  end
end