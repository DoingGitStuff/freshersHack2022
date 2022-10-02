defmodule Wordle.Word do
  defstruct guesses: [[]], word: nil
  alias Wordle.Word
  def new() do
    %Word{word: Wordle.Words.random()}
  end
  def new(word) do
    %Word{word: word}
  end

  def add_key(%Word{guesses: guesses}=word,key) do
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)

    unless length(curr_guess) == 5 do
      new_guess = curr_guess ++ [String.downcase(key)]
      new_guesses = prev_guesses ++ [new_guess]
      %{ word | guesses: new_guesses}
    else
      word
    end
  end

  def remove_letter(%Word{}=wordle) do
    {prev_guesses,curr_guess} = curr_and_prev(wordle)
    guess_len = length(curr_guess)
    {guess,_} = Enum.split(curr_guess,guess_len-1)
    new_guesses = prev_guesses++[guess]
    %{wordle | guesses: new_guesses}
  end

  def current(%Word{}=wordle) do
    {_,w}= curr_and_prev(wordle)
    w
  end
  def previous(%Word{}=wordle) do
    {ws,_} = curr_and_prev(wordle)
    ws
  end
  def curr_and_prev(%Word{}=wordle) do
    guesses = wordle.guesses
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)
    {prev_guesses,curr_guess}
  end

  def check(%Word{}=wordle) do
    {prev_guesses,curr_guess} = curr_and_prev(wordle)
    IO.inspect(prev_guesses,label: :prev)
    IO.inspect(curr_guess,label: "curr")
    if length(curr_guess) == 5 do
      checked = Wordle.Words.check(wordle.word,curr_guess)
      new_guesses = prev_guesses ++ [checked] ++ [[]]
      IO.inspect(checked,label: "checked")
      new_wordl = %{ wordle | guesses: new_guesses}
      correct? = Enum.all?(checked,fn
        {:correct,_} -> true
        _ -> false end)
      if correct? do
        {:correct,new_wordl}
      else
        {:incorrect,new_wordl}
      end
    else
      wordle
    end
  end

end
