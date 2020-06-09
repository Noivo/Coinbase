defmodule Demo.Tracker do
  use GenServer
  alias Demo.Coinbase

  @topic "conversions"

  # Public API

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def last_conversion_rates do
    GenServer.call(__MODULE__, :last_conversion_rates, 25000)
  end

  # Private API
  def init(state) do
    send(self(), :work)
    {:ok, state}
  end

  def handle_call(:last_conversion_rates, _, [head | _] = state) do
    {:reply, head, state}
  end

  def handle_info(:work, state) do
    state = update_state(state)

    [head | _] = state

    broadcast({:ok, head}, :new_rates)
    Process.send_after(self(), :work, 5000)
    {:noreply, state}
  end

  def update_state(state) do
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
