defmodule Demo.Tracker do
  use GenServer
  alias Demo.Coinbase

  @topic "conversions"

  # Public API

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def history do
    GenServer.call(__MODULE__, :history, 25000)
  end

  # Private API
  def init(state) do
    send(self(), :work)
    {:ok, state}
  end

  def handle_call(:history, _, state) do
    {:reply, state, state}
  end

  def handle_info(:work, state) do
    history = update_history(state)
    head = List.first(history)

    broadcast({:ok, head}, :history)
    Process.send_after(self(), :work, 5000)
    {:noreply, state}
  end

  def update_history(state) do
    with {:ok, result} <- Coinbase.products() do
      [result | state]
    else
      _ -> state
    end
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Demo.PubSub, @topic)
  end

  defp broadcast({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Demo.PubSub, @topic, {event, result})
  end
end
