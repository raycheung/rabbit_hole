defmodule RabbitHole.RPCServer do
  use Supervisor
  alias RabbitHole.RPCReceiver
  alias RabbitHole.RPCDispatcher

  def start_link(queue_name, handler) when is_bitstring(queue_name) and is_atom(handler) do
    Supervisor.start_link(__MODULE__, [queue_name, handler])
  end

  def init([queue_name, handler]) do
    name = String.to_atom("#{__MODULE__}.#{queue_name}")
    children = [
      worker(RPCReceiver, [name, queue_name]),
      supervisor(RPCDispatcher, [name, handler])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
