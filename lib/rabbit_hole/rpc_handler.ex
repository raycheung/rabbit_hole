defmodule RabbitHole.RPCHandler do

  @callback on_message(payload :: term) :: {:ok, response :: term} | {:error, reason :: term}

  defmacro __using__(_) do
    quote location: :keep do
      @behaviour RabbitHole.RPCHandler

      alias AMQP.Basic

      @exchange ""
      def start_link({payload, meta, channel}) do
        Task.start_link fn ->
          case on_message(payload) do
            {:ok, response} ->
              Basic.publish channel, @exchange, meta.reply_to, response, correlation_id: meta.correlation_id
              Basic.ack channel, meta.delivery_tag
            {:error, _reason} ->
              Basic.nack channel, meta.delivery_tag
          end
        end
      end
    end
  end
end
