defmodule WordleWeb.SingleLive do
  use Phoenix.LiveView

  def render(assigns) do
    # <p>The word is <%= @player.word %></p>
    ~H"""
    <div class="multi-wordle-box" >
      <div class="wordle-status">
      <%= if @started do %>
      Started
      <% else %>
      Not started yet
      <% end %>
      </div>
      <div phx-window-keyup="wordle_keyup" class="wordle-box wd-player">
        <div class="wordle">
        <%= for guess <- @player.guesses do %>
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
      <div class="wordle-box wd-opponent">
        <div class="wordle">
          <%= for guess <- @opponent.guesses do %>
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
    </div>
    """
  end

  def mount(_param,_session,socket) do
    if not Wordle.Lobby.joined?(Wordle.Lobby) do
      Wordle.Lobby.join(Wordle.Lobby)
    end
      {:ok,assign(socket,player: Wordle.Word.new(""),opponent: Wordle.Word.new(""),started: false,channel: nil)}
  end


  @letters Enum.flat_map(?a..?z,&([<<&1>>, <<&1-32>>]))
  defp guesses(socket), do: socket.assigns.guesses
  defp word(socket), do: socket.assigns.word
  defp started?(socket), do: socket.assigns.started
  defp sent_state(socket,state) do
    Wordle.Lobby.send_update(socket.assigns.channel,state)
    assign(socket,player: state)
  end
  def handle_event("wordle_keyup",%{"key"=>key},socket) when key in @letters do
    unless started?(socket) do
      {:noreply,socket}
    else
      new = Wordle.Word.add_key(socket.assigns.player,key)
      {:noreply,sent_state(socket,new)}
    end
  end

  def handle_event("wordle_keyup",%{"key"=>"Enter"},socket) do
    unless started?(socket) do
      {:noreply, socket}
    else
      case Wordle.Word.check(socket.assigns.player) do
        {:incorrect,new} -> {:noreply,sent_state(socket, new)}
        {:correct,new} -> {:noreply,sent_state(socket,new)}
        _ ->
          {:noreply, socket}
      end
    end
  end

  def handle_event("wordle_keyup",%{"key"=>"Backspace"},socket) do
    unless started?(socket) do
      {:noreply,socket}
    else
      new = Wordle.Word.remove_letter(socket.assigns.player)
      IO.inspect(new)
      {:noreply,sent_state(socket, new )}
    end
  end

  def handle_event("wordle_keyup",%{"key"=>_},socket) do
    {:noreply,socket}
  end

  def handle_info({:join,pid,word},socket) do
    Process.monitor(pid)
    {:noreply, assign(socket,channel: pid,player: word,opponent: word,started: true)}
  end
  def handle_info({:DOWN,_ref,:process,_object,_reason},socket) do
    Wordle.Lobby.join(Wordle.Lobby)
    {:noreply, assign(socket,channel: nil,player: Wordle.Word.new(""),opponent: Wordle.Word.new(""),started: false)}
  end

  def handle_info({:opponent,state},socket) do
    {:noreply,assign(socket,opponent: state)}
  end

  def terminate(_reason,socket) do
    case socket.assigns.channel do
      nil -> nil
      pid -> send(pid,{:DOWN,self(),:process,nil,"terminated"})
    end
  end
end
