defmodule GenServerTimeoutBattery.Parent do
  use GenServer

  alias GenServerTimeoutBattery.Child

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, [], opts)
  end

  def start_child(opts) do
    GenServer.call(__MODULE__, {:start_child, opts})
  end

  def stop_child(child_id) do
    GenServer.call(__MODULE__, {:stop_child, child_id})
  end

  ###
  #
  # Server
  #
  ###

  @impl true
  def init(_args) do
    {
      :ok,
      %{}
    }
  end

  @impl true
  def handle_call({:start_child, opts}, _from, state) do
    child_id = UUID.uuid1(:hex)

    {:ok, sspid} =
      Child.start_link(
        child_id,
        opts[:timeout_duration],
        self()
      )

    {
      :reply,
      child_id,
      Map.put_new(state, child_id, [pid: sspid, reporter_process: opts[:reporter_process]])
    }
  end

  @impl true
  def handle_call({:stop_child, child_id}, _from, state) do
    cond do
      Map.has_key?(state, child_id) ->
        {
          :reply,
          GenServer.stop(state[child_id][:pid]),
          Map.delete(state, child_id)
        }

      true ->
        {:reply, :not_found, state}
    end
  end

  @impl true
  def handle_info({:inactive, child_id}, state) do
    IO.puts('Closing Child due to inactivity: #{child_id}}')
    :ok = GenServer.stop(state[child_id][:pid])
    if is_pid(state[child_id][:reporter_process]), do: send(state[child_id][:reporter_process], {:terminated, child_id})
    {
      :noreply,
      Map.delete(state, child_id)
    }
  end
end
