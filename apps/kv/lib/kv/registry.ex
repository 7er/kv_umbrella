defmodule KV.Registry do
  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """
  def start_link(table, event_manager, buckets, opts \\ []) do
    GenServer.start_link(__MODULE__, {table, event_manager, buckets}, opts)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `server`.

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(table, name) do
    case :ets.lookup(table, name) do
      [{^name, bucket}] -> {:ok, bucket}
      [] -> :error
    end
  end

  @doc """
  Ensures there is a bucket associated to the given `name` in `server`.
  """
  def create(server, name) do
    GenServer.call(server, {:create, name})
  end

  ## Server Callbacks

  def init({names, events, buckets}) do
    refs = :ets.foldl(
      fn {name, pid}, acc ->
        HashDict.put(acc, Process.monitor(pid), name)
      end,
      HashDict.new,
      names)
    {:ok, %{names: names, refs: refs, events: events, buckets: buckets}}
  end

  def handle_call({:create, name}, _from, state) do
    case lookup(state.names, name) do
      {:ok, bucket} ->
        {:reply, bucket, state} # already exists
      :error ->
        {:ok, bucket} = KV.Bucket.Supervisor.start_bucket(state.buckets)
        refs = HashDict.put(
          state.refs,
          Process.monitor(bucket),
          name)
        #names = HashDict.put(state.names, name, bucket)
        :ets.insert(state.names, {name, bucket})
        # push notification to event manager
        GenEvent.sync_notify(state.events, {:create, name, bucket})
      {:reply, bucket, %{state | refs: refs}}
    end
  end

  def handle_info({:DOWN, ref, :process, pid, _reason}, state) do
    {name, refs} = HashDict.pop(state.refs, ref)
    :ets.delete(state.names, name)
    # 4. Push a notification to the event manager on exit
    GenEvent.sync_notify(state.events, {:exit, name, pid})
    {:noreply, %{state | refs: refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end  
end
