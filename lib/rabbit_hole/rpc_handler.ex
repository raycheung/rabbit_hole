defmodule RabbitHole.RPCHandler do
  alias AMQP.Basic

  @callback on_message(payload :: term) :: {:ok, response :: term} | {:error, reason :: term}

  defmacro __using__(_) do
    quote location: :keep do
      alias RabbitHole.RPCHandler
      @behaviour RPCHandler

      def start_link(message) do
        Task.start_link(fn -> RPCHandler.process_message(message, &on_message/1) end)
      end
    end
  end

  @exchange ""
  def process_message({payload, meta, channel}, func) do
    case func.(payload) do
      {:ok, response} ->
        Basic.publish channel, @exchange, meta.reply_to, response, correlation_id: meta.correlation_id
        Basic.ack channel, meta.delivery_tag
      {:error, _reason} ->
        Basic.nack channel, meta.delivery_tag
    end
  end
end
