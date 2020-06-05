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
    head = Tracker.history()
    socket = assign(socket, :conversions, head)
    {:noreply, socket}
  end

  def handle_info({:history, result}, socket) do
    socket = assign(socket, :conversions, result)
    {:noreply, socket}
  end
end
