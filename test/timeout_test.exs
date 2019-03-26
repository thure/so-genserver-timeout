defmodule GenServerTimeoutBattery.Tests do
  use ExUnit.Case

  alias GenServerTimeoutBattery.{Parent, Child}

  test "child sends inactivity signal on timeout" do
    id = UUID.uuid4(:hex)

    assert {:ok, cpid} = Child.start_link(id, 2000, self())

    assert "potato" == Child.get_data(id)

    assert_receive {:inactive, child_id}, 3000

    assert child_id == id

    assert :ok = GenServer.stop(cpid)
  end

  test "parent receives inactivity signal from child" do
    assert {:ok, ppid} = Parent.start_link(name: Parent)

    assert child_id = Parent.start_child(timeout_duration: 2000, reporter_process: self())

    assert "potato" == Child.get_data(child_id)

    assert_receive {:terminated, child_id}, 3000

    assert :ok = GenServer.stop(ppid)
  end

end
