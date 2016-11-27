defmodule RabbitHole do
  alias AMQP.Connection

  def connection do
    with {:ok, connection} <- Connection.open(rabbitmq_url), do: connection
  end

  def rabbitmq_url do
    System.get_env("RABBITMQ_URL") || "amqp://guest:guest@localhost"
  end
end
