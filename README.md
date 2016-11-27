# RabbitHole

A simplified interface for RPC over RabbitMQ.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `rabbit_hole` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:rabbit_hole, "~> 0.2.0"}]
    end
    ```

  2. Ensure `rabbit_hole` is started before your application:

    ```elixir
    def application do
      [applications: [:rabbit_hole]]
    end
    ```

