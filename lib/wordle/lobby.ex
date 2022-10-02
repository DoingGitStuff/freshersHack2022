defmodule Wordle.Lobby do
  use GenServer

  def init(_opts) do
    {:ok,[]}
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__,[],opts)
  end

  def handle_cast({:match,pid},[]) do
    {:noreply,[pid]}
  end
  def handle_cast({:match,pid1},[pid2 | _tl]) do
    new_word = Wordle.Word.new()
    send(pid2,{:join,pid1,new_word})
    send(pid1,{:join,pid2,new_word})
    {:noreply,[]}
  end
  def handle_call(:matching?,pid,state) do
    yes? = pid in state
    {:reply, yes?,state}
  end

  def join(name) do
    GenServer.cast(name,{:match,self()})
  end

  def joined?(name) do
    GenServer.call(name,:matching?)
  end

  def send_msg(l,msg) do
    send(l,msg)
  end
  def send_update(pid,state) do
    send_msg(pid,{:opponent,state})
  end
end
