defmodule WordleWeb.CounterLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <p> Count: <%= @count %> </p>
    <button phx-click="inc_count">+</button>
    <button phx-click="dec_count">-</button>
    """
  end

  def mount(_params, _session, socket) do
      Phoenix.PubSub.subscribe(Wordle.PubSub,"count")
      {:ok,assign(socket,count: Wordle.Counter.state())}
  end
  def handle_event("inc_count",_val,socket) do
    {:noreply,assign(socket,count: broadcasted( Wordle.Counter.inc()))}
  end
  def handle_event("dec_count",_val,socket) do
    {:noreply,assign(socket,count: broadcasted(Wordle.Counter.dec()))}
  end

  defp broadcasted(val) do
    Phoenix.PubSub.broadcast(Wordle.PubSub,"count",{:count,val})
    val
  end

  def handle_info({:count,count},socket) do
    {:noreply,assign(socket,count: count)}
  end


end
