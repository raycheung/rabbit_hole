defmodule RabbitHoleTest do
  use ExUnit.Case, async: true
  # doctest RabbitHole

  @queue "rpc_queue"
  @timeout 3_000

  defmodule Handler do
    use RabbitHole.RPCHandler

    def on_message(payload), do: {:ok, "response of #{payload}"}
  end

  @exchange ""
  def rpc_call(queue, msg) do
    {:ok, connection} = AMQP.Connection.open(RabbitHole.rabbitmq_url)
    {:ok, channel} = AMQP.Channel.open(connection)
    {:ok, %{queue: reply_queue}} = AMQP.Queue.declare(channel, "", exclusive: true)
    AMQP.Basic.consume(channel, reply_queue, nil, no_ack: true)
    correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64
    AMQP.Basic.publish(channel, @exchange, queue, msg, reply_to: reply_queue, correlation_id: correlation_id)
    correlation_id
  end

  test "pass the request to the handler, and response is sent to the reply queue" do
    {:ok, _} = RabbitHole.RPCServer.start_link(@queue, Handler)
    correlation_id = rpc_call(@queue, "12345678")
    assert_receive {:basic_deliver, "response of 12345678", %{correlation_id: ^correlation_id}}
  end

  test "process messages that are already in the queue" do
    [c_id1, c_id2, c_id3] = [rpc_call(@queue, "123"), rpc_call(@queue, "456"), rpc_call(@queue, "789")]
    {:ok, _} = RabbitHole.RPCServer.start_link(@queue, Handler)
    assert_receive {:basic_deliver, "response of 123", %{correlation_id: ^c_id1}}
    assert_receive {:basic_deliver, "response of 456", %{correlation_id: ^c_id2}}
    assert_receive {:basic_deliver, "response of 789", %{correlation_id: ^c_id3}}
  end
end
