alias Experimental.GenStage

defmodule RabbitHole.RPCReceiver do
  use GenStage
  alias AMQP.Connection
  alias AMQP.Channel
  alias AMQP.Queue
  alias AMQP.Basic
  require Logger

  def start_link(name, queue_name) when is_bitstring(queue_name) do
    GenStage.start_link(__MODULE__, queue_name, name: name)
  end

  def init(queue_name) do
    {:ok, connection} = Connection.open(RabbitHole.rabbitmq_url)
    {:ok, channel} = Channel.open(connection)
    {:ok, queue} = Queue.declare(channel, queue_name, durable: true)
    Basic.consume channel, queue_name
    Logger.debug ["Consuming queue:", inspect(queue)]
    {:producer, channel}
  end

  def handle_demand(_demand, channel), do: {:noreply, [], channel}

  def handle_info({:basic_consume_ok, _consumer}, channel), do: {:noreply, [], channel}
  def handle_info({:basic_deliver, payload, meta}, channel) do
    Logger.info ["Received message:", inspect(payload), " with meta:", inspect(meta)]
    {:noreply, [{payload, meta, channel}], channel}
  end
end
