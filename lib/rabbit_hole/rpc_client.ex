defmodule RabbitHole.RPCClient do
  alias AMQP.{Basic, Channel, Queue}

  defstruct [:channel]

  def start(connection \\ RabbitHole.connection) do
    {:ok, channel} = Channel.open(connection)
    {:ok, %__MODULE__{channel: channel}}
  end

  @exchange ""
  def call(%__MODULE__{channel: channel}, queue, message) do
    with {:ok, %{queue: reply_queue}} <- Queue.declare(channel, "", exclusive: true),
      {:ok, _} <- Basic.consume(channel, reply_queue, nil, no_ack: true),
      correlation_id = :erlang.unique_integer |> :erlang.integer_to_binary |> Base.encode64,
      :ok <- Basic.publish(channel, @exchange, queue, message, reply_to: reply_queue, correlation_id: correlation_id) do
      correlation_id
    end
  end
end
