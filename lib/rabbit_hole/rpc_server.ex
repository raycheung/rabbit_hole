defmodule RabbitHole.RPCServer do
  use Supervisor

  @doc ~S"""
  Start a RPC server for `queue_name` with `handler`.

  Each RPC message received from the queue would be dispatched a process running the handler.
  """
  def start_link(queue_name, handler, connection \\ RabbitHole.connection) when is_bitstring(queue_name) and is_atom(handler) do
    Supervisor.start_link(__MODULE__, [connection, queue_name, handler])
  end

  def init([connection, queue_name, handler]) do
    name = String.to_atom("#{__MODULE__}.#{queue_name}")
    children = [
      worker(RabbitHole.RPCReceiver, [name, connection, queue_name]),
      supervisor(RabbitHole.RPCDispatcher, [name, handler])
    ]

    supervise(children, strategy: :one_for_one)
  end
end
