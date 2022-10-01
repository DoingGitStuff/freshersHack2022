defmodule Wordle.Word do
  defstruct guesses: [[]], word: nil
  alias Wordle.Word
  def new() do
    %Word{word: Wordle.Words.random()}
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
    guesses = wordle.guesses
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)
    guess_len = length(curr_guess)
    {guess,_} = Enum.split(curr_guess,guess_len-1)
    new_guesses = prev_guesses++[guess]
    %{wordle | guesses: new_guesses}
  end

  def check(%Word{}=wordle) do
    guesses= wordle.guesses
    word = wordle.word
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)
    if length(curr_guess) == 5 do
      checked = Wordle.Words.check(word,curr_guess)
      # correct? = Enum.all?(checked,fn
      #   {:correct,_} -> true
      #   _ -> false end)
      new_guesses = prev_guesses ++ [checked] ++ [[]]
      %{ wordle | guesses: new_guesses}
    else
      wordle
    end
  end




end
