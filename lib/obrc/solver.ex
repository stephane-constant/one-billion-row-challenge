defmodule OneBillionRowChallenge.Solver do
  @moduledoc """
  Documentation for `OneBillionRowChallenge.Solver`.
  """

  @doc """
  Reads the input file, parses the city name and the temperature, groups them by city,
  then computes and displays the min / mean / max temperature per city.

  ## Examples

      iex> OneBillionRowChallenge.Solver.run("data/measurements_small.txt")
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
         results <-
           File.stream!(puzzle_filename, [:read])
           |> Enum.map(&String.trim/1)
           |> Enum.map(&String.split(&1, ";"))
           |> Enum.map(fn [city | temperature] ->
             %{city: city, temp: String.to_float(Enum.at(temperature, 0))}
           end)
           |> Enum.group_by(&(&1.city), &(&1.temp))
           |> Enum.map(fn {city, temperatures} ->
             %{city: city,
               min: Enum.min(temperatures),
               max: Enum.max(temperatures),
               mean: Enum.sum(temperatures) / Enum.count(temperatures)
             }
           end),
         finish_time <- Time.utc_now()
      do

        results
        |> Enum.each(fn x ->
          IO.puts("#{x.city}=#{Float.round(x.min, 1)}/#{Float.round(x.mean)}/#{Float.round(x.max)}")
        end)

        duration_in_ms = Time.diff(finish_time, start_time, :millisecond)
        IO.puts("It took #{duration_in_ms} milliseconds to process the file (before display of results).")
    end
  end

end
