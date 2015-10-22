defmodule KV.RegistryTest do
  use ExUnit.Case, async: true

  defmodule Forwarder do
    use GenEvent
    
    def handle_event(event, parent) do
      send parent, event
      {:ok, parent}
    end
  end
  
  setup do
    table_name = :registry_table
    table = :ets.new(table_name, [:set, :public])
    registry = start_registry(table)
    {:ok, registry: registry, table: table}
  end

  defp start_registry(table) do
    {:ok, supervisor} = KV.Bucket.Supervisor.start_link
    {:ok, manager} = GenEvent.start_link
    {:ok, registry} = KV.Registry.start_link(table, manager, supervisor)
    GenEvent.add_mon_handler(manager, Forwarder, self())
    registry
  end
  

  test "sends events on create and crash", %{registry: registry, table: table} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(table, "shopping")
    assert_receive {:create, "shopping", ^bucket}

    Agent.stop(bucket)
    assert_receive {:exit, "shopping", ^bucket}
  end

  test "spawns buckets", %{registry: registry, table: table} do
    assert KV.Registry.lookup(table, "shopping") == :error

    KV.Registry.create(registry, "shopping")
    assert {:ok, bucket} = KV.Registry.lookup(table, "shopping")

    KV.Bucket.put(bucket, "milk", 1)
    assert KV.Bucket.get(bucket, "milk") == 1
  end

  test "removes buckets on exit", %{registry: registry, table: table} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(table, "shopping")
    Agent.stop(bucket)
    assert_receive({:exit, "shopping", ^bucket})
    assert KV.Registry.lookup(table, "shopping") == :error
  end  

  test "removes bucket on crash", %{registry: registry, table: table} do
    KV.Registry.create(registry, "shopping")
    {:ok, bucket} = KV.Registry.lookup(table, "shopping")
    # Kill the bucket and wait for notify
    Process.exit(bucket, :shutdown)
    assert_receive({:exit, "shopping", ^bucket})
    assert KV.Registry.lookup(table, "shopping") == :error
  end

  test "monitors existing entries", %{registry: registry, table: ets} do
    bucket = KV.Registry.create(registry, "shopping")

    # Kill the registry. We unlink first, otherwise it will kill the test
    Process.unlink(registry)
    Process.exit(registry, :shutdown)

    # Start a new registry with the existing table and access the bucket
    start_registry(ets)
    assert KV.Registry.lookup(ets, "shopping") == {:ok, bucket}

    # Once the bucket dies, we should receive notifications
    Process.exit(bucket, :shutdown)
    assert_receive {:exit, "shopping", ^bucket}
    assert KV.Registry.lookup(ets, "shopping") == :error
  end
  
end
