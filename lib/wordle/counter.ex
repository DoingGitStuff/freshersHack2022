defmodule Wordle.Counter do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__,0,name: __MODULE__)
  end

  def inc() do
    GenServer.call(__MODULE__,:inc)
  end

  def dec() do
    GenServer.call(__MODULE__,:dec)
  end
  def state() do
    GenServer.call(__MODULE__,:state)
  end


  def init(count) do
    {:ok,count}
  end

  def handle_call(:inc,_from,state) do
    change(state,+1)
  end
  def handle_call(:dec,_from,state) do
    change(state,-1)
  end
  def handle_call(:state,_from,state) do
    change(state,0)
  end

  defp change(state,diff) do
    new = state + diff
    {:reply,new,new}
    # with :ok <- PubSub.broadcast(Wordle.PubSub,@topic,new) do
    #   {:reply, new}
    # else
    #   {:error,_reason} ->
    #     {:reply, state}
    # end

  end
end
