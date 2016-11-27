defmodule RabbitHoleTest do
  use ExUnit.Case, async: true

  @queue "rpc_queue"
  @timeout 3_000

  defmodule GoodHandler do
    use RabbitHole.RPCHandler

    def on_message(payload), do: {:ok, "response of #{payload}"}
  end

  defmodule BadHandler do
    use RabbitHole.RPCHandler

    def on_message(_payload), do: {:error, "BOOM!!!"}
  end

  def consume_messages(channel, queue, count \\ 0) do
    case AMQP.Basic.get(channel, queue) do
      {:empty, _} when count > 0 -> count
      _ -> consume_messages(channel, queue, count + 1)
    end
  end

  setup do
    {:ok, rpc_client} = RabbitHole.RPCClient.start
    %{rpc_client: rpc_client}
  end

  test "pass the request to the handler, and response is sent to the reply queue", %{rpc_client: rpc_client} do
    {:ok, _} = RabbitHole.RPCServer.start_link(@queue, GoodHandler)
    correlation_id = RabbitHole.RPCClient.call(rpc_client, @queue, "12345678")
    assert_receive {:basic_deliver, "response of 12345678", %{correlation_id: ^correlation_id}}
  end

  test "process messages that are already in the queue", %{rpc_client: rpc_client} do
    expectation = [{"123", "response of 123"}, {"456", "response of 456"}, {"789", "response of 789"}]
    correlation_ids = expectation |> Keyword.keys |> Enum.map(&(RabbitHole.RPCClient.call(rpc_client, @queue, &1)))
    {:ok, _} = RabbitHole.RPCServer.start_link(@queue, GoodHandler)
    expectation
    |> Keyword.values
    |> Enum.zip(correlation_ids)
    |> Enum.each(fn {resp, correlation_id} ->
      assert_receive {:basic_deliver, ^resp, %{correlation_id: ^correlation_id}}
    end)
  end

  test "leave message unprocessed on error", %{rpc_client: rpc_client = %{channel: channel}} do
    unique_name = "#{@queue}-#{:erlang.unique_integer}"
    {:ok, %{queue: queue}} = AMQP.Queue.declare(channel, unique_name, durable: true)
    _correlation_id = RabbitHole.RPCClient.call(rpc_client, queue, "doesn't matter")
    {:ok, server} = RabbitHole.RPCServer.start_link(queue, BadHandler)
    assert 1 == consume_messages(channel, queue)
    GenServer.stop(server, :normal)
    AMQP.Queue.delete(channel, queue)
  end
end
