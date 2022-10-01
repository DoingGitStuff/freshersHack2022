defmodule WordleWeb.SingleLive do
  use Phoenix.LiveView

  def render(assigns) do
    ~H"""
    <div id="wordle" phx-window-keyup="wordle_keyup">
      <p>The word is <%= @word %></p>
      <table class="wordle">
      <%= for guess <- @guesses do %>
        <tr>
        <%= for letter <- guess do %>

          <%= case letter do %>
          <% {:correct,l} -> %>
          <td id="correct"> <%= l %> </td>
          <% {:present,l} -> %>
          <td id="present"> <%= l %> </td>
          <% {:incorrect, l} -> %>
          <td id="incorrect"> <%= l %> </td>
          <% _ -> %>
          <td> <%= letter %> </td>
          <% end %>

        <% end %>
        </tr>
      <% end %>
      </table>
    </div>
    """
  end


  def mount(_param,_session,socket) do
    unless Map.has_key?(socket.assigns,:word) do
      {:ok,assign(socket,word: Wordle.Words.random(), guesses: [[]])}
    else
      {:ok,socket}
    end
  end




  @letters Enum.flat_map(?a..?z,&([<<&1>>, <<&1-32>>]))
  defp guesses(socket), do: socket.assigns.guesses
  defp word(socket), do: socket.assigns.word
  def handle_event("wordle_keyup",%{"key"=>key},socket) when key in @letters do
    IO.inspect(key, label: :letter)
    guesses = guesses(socket)
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)

    unless length(curr_guess) == 5 do
      new_guess = curr_guess ++ [key]
      {:noreply,assign(socket,guesses: prev_guesses ++ [new_guess])}
    else
      {:noreply,socket}
    end
  end

  def handle_event("wordle_keyup",%{"key"=>"Enter"},socket) do
    IO.inspect(:ENTER)
    guesses = guesses(socket)
    guess_no = length(guesses)
    {prev_guesses,[curr_guess]} = Enum.split(guesses,guess_no-1)
    if length(curr_guess) == 5 do
      IO.inspect(guesses)
      word = word(socket)
      checked = Wordle.Words.check(word,curr_guess)
      correct? = Enum.all?(checked,fn
        {:correct,_} -> true
        _ -> false end)
      unless correct? do
        {:noreply,assign(socket,guesses: prev_guesses ++ [checked] ++ [[]])}
      else
        {:noreply,assign(socket,guesses: prev_guesses ++ [checked] ++ [[]])}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("wordle_keyup",%{"key"=>"Backspace"},socket) do
    IO.inspect(:BACKSPACE)
    {:noreply,socket}
  end

  def handle_event("wordle_keyup",%{"key"=>_},socket) do
    {:noreply,socket}
  end
end
