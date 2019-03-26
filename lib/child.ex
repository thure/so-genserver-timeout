defmodule GenServerTimeoutBattery.Child do
  @moduledoc """
    The Child server which sends its timeout to the parent
  """

  use GenServer

  def start_link(child_id, timeout_duration, parent_pid) do
    GenServer.start_link(__MODULE__, [child_id, timeout_duration, parent_pid], [name: String.to_atom(child_id)])
  end

  def get_data(child_id) do
    GenServer.call(String.to_atom(child_id), :get_data)
  end

  @impl true
  def init([child_id, timeout_duration, parent_pid]) do
    IO.puts('Timeout of #{timeout_duration} set for')
    IO.inspect(child_id)
    {
      :ok,
      %{
        data: "potato",
        child_id: child_id,
        parent_process: parent_pid
      },
      timeout_duration
    }
  end

  @impl true
  def handle_call(:get_data, _from, state) do
    IO.puts('Get data for #{state.child_id}')
    {
      :reply,
      state.data,
      state
    }
  end

  @impl true
  def handle_info(:timeout, state) do
    # Hibernates and lets the parent decide what to do.
    IO.puts('Sending timeout for #{state.child_id}')
    if is_pid(state.parent_process), do: send(state.parent_process, {:inactive, state.child_id})

    {
      :noreply,
      state,
      :hibernate
    }
  end
end
