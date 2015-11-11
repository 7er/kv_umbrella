defmodule :"Elixir..KeyValue"ControllerTest do
  use .ConnCase

  alias :"Elixir..KeyValue"
  @valid_attrs %{key: "some content", value: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, key_value_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    key_value = Repo.insert! %KeyValue"{}
    conn = get conn, key_value_path(conn, :show, key_value)
    assert json_response(conn, 200)["data"] == %{"id" => key_value.id,
      "key" => key_value.key,
      "value" => key_value.value}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, key_value_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, key_value_path(conn, :create), key_value: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(KeyValue", @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, key_value_path(conn, :create), key_value: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    key_value = Repo.insert! %KeyValue"{}
    conn = put conn, key_value_path(conn, :update, key_value), key_value: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(KeyValue", @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    key_value = Repo.insert! %KeyValue"{}
    conn = put conn, key_value_path(conn, :update, key_value), key_value: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    key_value = Repo.insert! %KeyValue"{}
    conn = delete conn, key_value_path(conn, :delete, key_value)
    assert response(conn, 204)
    refute Repo.get(KeyValue", key_value.id)
  end
end
