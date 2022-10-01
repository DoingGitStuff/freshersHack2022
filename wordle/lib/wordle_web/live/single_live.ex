defmodule WordleWeb.SingleLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div phx-window-keyup="wordle_keyup" class="wordleBox">
      <p>The word is <%= @word %></p>
      <div class="wordle">
      <%= for guess <- @guesses do %>
        <%= for letter <- guess do %>
          <div>
          <%= case letter do %>
          <% {:correct,l} -> %>
          <div class="letter correct"> <%= l %> </div>
          <% {:present,l} -> %>
          <div  class="letter present"> <%= l %> </div>
          <% {:incorrect, l} -> %>
          <div class="letter incorrect"> <%= l %> </div>
          <% _ -> %>
          <div class="letter unchecked"> <%= letter %> </div>
          <% end %>
          </div>
        <% end %>
      <% end %>
      </div>
    </div>
    """
  end


  def mount(_param,_session,socket) do
    unless Map.has_key?(socket.assigns,:word) and Map.has_key?(socket.assigns,:guesses) do
      {:ok,assign(socket,word: Wordle.Words.random(), guesses: [[]])}
    else
      {:ok,socket}
    end
  end




  @letters Enum.flat_map(?a..?z,&([<<&1>>, <<&1-32>>]))
  defp guesses(socket), do: socket.assigns.guesses
  defp word(socket), do: socket.assigns.word
  def handle_event("wordle_keyup",%{"key"=>key},socket) when key in @letters do
    guesses = guesses(socket)
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)

    unless length(curr_guess) == 5 do
      new_guess = curr_guess ++ [String.downcase(key)]
      new_guesses = prev_guesses ++ [new_guess]
      {:noreply,assign(socket,guesses: new_guesses )}
    else
      {:noreply,socket}
    end
  end

  def handle_event("wordle_keyup",%{"key"=>"Enter"},socket) do
    guesses = guesses(socket)
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)
    if length(curr_guess) == 5 do
      word = word(socket)
      checked = Wordle.Words.check(word,curr_guess)
      # correct? = Enum.all?(checked,fn
      #   {:correct,_} -> true
      #   _ -> false end)
      new_guesses = prev_guesses ++ [checked] ++ [[]]
      {:noreply,assign(socket,guesses: new_guesses)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("wordle_keyup",%{"key"=>"Backspace"},socket) do
    guesses = guesses(socket)
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)
    guess_len = length(curr_guess)
    {guess,_} = Enum.split(curr_guess,guess_len-1)
    new_guesses = prev_guesses++[guess]
    {:noreply,assign(socket,guesses: new_guesses)}
  end

  def handle_event("wordle_keyup",%{"key"=>_},socket) do
    {:noreply,socket}
  end
end
