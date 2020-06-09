defmodule DemoWeb.TrackerLive do
  use DemoWeb, :live_view
  alias DemoWeb.TrackerView
  alias Demo.Tracker

  def mount(_params, _session, socket) do
    if connected?(socket), do: Tracker.subscribe()
    socket = assign(socket, :conversions, [])
    {:ok, socket}
  end

  def render(assigns) do
    TrackerView.render("tracker_live.html", assigns)
  end

  def handle_event("new", _, socket) do
    conversion_rates = Tracker.last_conversion_rates()
    socket = assign(socket, :conversions, conversion_rates)
    {:noreply, socket}
  end

  @spec handle_info({:last_conversion_rates, any}, Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_info({:last_conversion_rates, result}, socket) do
    socket = assign(socket, :conversions, result)
    {:noreply, socket}
  end
end
