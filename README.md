# RabbitHole

A simplified interface for RPC over RabbitMQ.

## Usage

RabbitHole provides a very simple interface to run a RPC server, all you need is to pass it with a handle module.

That is, define a `RabbitHole.RPCHandler` as following:
```elixir
defmodule EchoHandler
  use RabbitHole.RPCHandler

  def on_message(payload), do: {:ok, "response of #{payload}"}
end
```

Pass it to a `RabbitHole.RPCServer`:
```elixir
{:ok, server} = RabbitHole.RPCServer.start_link(queue_name, EchoHandler)
```
Or if you start it in a supervisor:
```elixir
def init
  children = [
    worker(RabbitHole.RPCServer, [queue_name, EchoHandler]),
  ]

  supervise(children, strategy: :one_for_one)
end
```

Then, for every message received from the message queue, it would be processed by the handler in a new process for concurrency.

The `RabbitHole.RPCClient` is also available if you want to start a RPC client:
```elixir
{:ok, rpc_client} = RabbitHole.RPCClient.start
correlation_id = RabbitHole.RPCClient.call(rpc_client, queue_name, request)
receive do
  {:basic_deliver, response, %{correlation_id: ^correlation_id}} ->
    IO.puts "Received response:#{response}"
  after 30_000 ->
    IO.puts "Timed out."
end
```

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

