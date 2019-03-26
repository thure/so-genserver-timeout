defmodule GenServerTimeoutBattery.Child do
  @moduledoc """
    The Child server which sends its timeout to the parent
  """

  use GenServer

  def start_link(child_id, timeout_duration, parent_pid) do
    GenServer.start_link(__MODULE__, [child_id, timeout_duration, parent_pid])
  end

  @impl true
  def init([child_id, timeout_duration, parent_pid]) do
    IO.puts('Timeout of #{timeout_duration} set for')
    IO.inspect(child_id)
    {
      :ok,
      %{
        child_id: child_id,
        parent_process: parent_pid
      },
      timeout_duration
    }
  end

  @impl true
  def handle_info(:timeout, state) do
    # Hibernates and lets the parent decide what to do.
    IO.puts('Sending timeout for')
    IO.inspect(state.child_id)
    if is_pid(state.parent_process), do: send(state.parent_process, {:inactive, state.child_id})

    {
      :noreply,
      state,
      :hibernate
    }
  end
end
