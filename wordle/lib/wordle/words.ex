defmodule Wordle.Words do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__,nil)
  end
  def init(_opts) do
    {:ok, nil, {:continue,:load_words}}
  end

  def handle_continue(:load_words,_state) do
    tab = :ets.new(:words,[:set,:protected,read_concurrency: true])
    state = load_words_to_tab(tab)
    :persistent_term.put(Wordle.Words,state)
    {:noreply, state,:hibernate}
  end

  def load_words_to_tab(tab) do
    {:ok, txt} = File.read("./priv/wordle-list-main/words")
    count = String.split(txt,"\n")
    |> Stream.with_index()
    |> Stream.map(fn {word,index} ->
      :ets.insert(tab,{index,word})
      1
      end)
    |> Enum.reduce(0,&(&1 + &2))

    %{count: count,table: tab}
    end

    def random() do
      %{table: tab, count: count} = :persistent_term.get(Wordle.Words)
      index = :rand.uniform(count)
      [{^index,word}|_] = :ets.lookup(tab,index)
      word
    end

    def check(word,guess) do
      letters = String.codepoints(word)
      Enum.zip(letters,guess)
      |> Enum.map(fn
        {a,a} -> {:correct,a}
        {_,b} -> if b in letters do {:present, b} else {:incorrect, b} end
      end)
    end
end
