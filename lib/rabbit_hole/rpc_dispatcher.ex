alias Experimental.DynamicSupervisor

defmodule RabbitHole.RPCDispatcher do
  use DynamicSupervisor

  def start_link(name, handler), do: DynamicSupervisor.start_link(__MODULE__, [name, handler])

  def init([name, handler]) do
    children = [worker(handler, [], restart: :transient)]

    {:ok, children, strategy: :one_for_one, subscribe_to: [{name, []}]}
  end
end
