# OneBillionRowChallenge

Coding challenge defined by the site https://www.programmez.com/actualites/one-billion-row-challenge-un-defi-de-programmation-java-36032

Objective : fastest app to read 1 billion rows of cities with temperatures, 
then compute and display average temperatures.

Set for Java developers, but done as Elixir training.

Generate data/measurements.txt (based on input weather_stations.csv, with 44691 entries): 
```shell
python3 create_measurements.py 1_000_000  
```

Launch the Elixir module:
```elixir
OneBillionRowChallenge.Solver.run("data/measurements.txt")
OneBillionRowChallenge.AsyncSolver.run("data/measurements.txt")
```

With basic implementation, on Linux Mint desktop / 8GB RAM / 4 CPU cores, it takes 
between 4 and 5 seconds to process the whole measurements file. Results display is not included. 

With worker/coordinator implementation (asynchronous computation of stats per city), 
it takes also between 4 and 5 seconds to process the whole measurements file.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `one_billion_row_challenge` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:one_billion_row_challenge, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/one_billion_row_challenge>.

