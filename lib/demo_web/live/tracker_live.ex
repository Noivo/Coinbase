defmodule DemoWeb.TrackerLive do
  use DemoWeb, :live_view
  alias Demo.Tracker

  def mount(_params, _session, socket) do
    if connected?(socket), do: Tracker.subscribe()
    socket = assign(socket, :conversions, [])
    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h1>Conversions: </h1>
    <button phx-click="new">Force Update</button>
    <table>
      <thead>
        <tr>
          <th>Conversion</th>
          <th>Price</th>
          <th>Size</th>
          <th>Bid</th>
          <th>Ask</th>
          <th>Volume</th>
          <th>Time</th>
        </tr>
      </thead>
      <tbody id ="conversions">

      <%= for item <- @conversions do %>
        <tr id="conversion-<%= item["time"]%>-<%= item["id"]%>">
          <td><%= item["id"] %></td>
          <td><%= item["price"] %></td>
          <td><%= item["size"] %></td>
          <td><%= item["bid"] %></td>
          <td><%= item["ask"] %></td>
          <td><%= item["volume"] %></td>
          <td><%= item["time"] %></td>
        </tr>
      <% end %>

      </tbody>
     </table>
    """
  end

  def handle_event("new", _, socket) do
    head = List.first(Tracker.history())
    socket = assign(socket, :conversions, head)
    {:noreply, socket}
  end

  def handle_info({:history, result}, socket) do
    socket = assign(socket, :conversions, result)
    {:noreply, socket}
  end
end
