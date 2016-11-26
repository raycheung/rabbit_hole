defmodule RabbitHole do
  def rabbitmq_url do
    System.get_env("RABBITMQ_URL") || "amqp://guest:guest@localhost"
  end
end
