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

  def coin_ticker(ticker) do
    GenServer.call(__MODULE__, {:coin_ticker, ticker})
  end

  def all_conversions do
    GenServer.call(__MODULE__, :all_conversions)
  end

  # Private API
  def init(state) do
    send(self(), :work)
    {:ok, state}
  end

  def handle_call(:last_conversion_rates, _, [head | _] = state) do
    {:reply, head, state}
  end

  def handle_call({:coin_ticker, ticker}, _, state) do
    {:ok, coin} = Coinbase.product(ticker)
    state = [%{ticker => coin}] ++ state
    {:reply, coin, state}
  end

  def handle_call(:all_conversions, _, [head | _] = state) do
    {:reply, head, state}
  end

  def handle_info(:work, state) do
    state =
      with {:ok, result} <- Coinbase.products() do
        [result] ++ state
      else
        error ->
          IO.inspect(error)
          state
      end

    head = List.first(state)

    broadcast({:ok, head}, :history)
    Process.send_after(self(), :work, 5000)
    {:noreply, state}
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Demo.PubSub, @topic)
  end

  defp broadcast({:ok, result}, event) do
    Phoenix.PubSub.broadcast(Demo.PubSub, @topic, {event, result})
  end

  defp broadcast({:error, _reason} = error, _event), do: error
end
