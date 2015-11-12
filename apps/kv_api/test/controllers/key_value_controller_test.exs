defmodule KvApi.KeyValueControllerTest do
  use KvApi.ConnCase

  @valid_attrs %{key: "some content", value: "some content"}
  @invalid_attrs %{}
  @bucket_id "shopping"

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "shows chosen resource", %{conn: conn} do
    key_value = nil # insert empty key value pair
    conn = get conn, bucket_key_value_path(conn, :show, @bucket_id, key_value)
    assert json_response(conn, 200)["data"] == %{"id" => key_value.id,
      "key" => key_value.key,
      "value" => key_value.value}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, bucket_key_value_path(conn, :show, @bucket_id, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, bucket_key_value_path(conn, :create, @bucket_id), key_value: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    # fetch key value here
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, bucket_key_value_path(conn, :create, @bucket_id), key_value: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
  key_value = nil # insert it here
    conn = put conn, bucket_key_value_path(conn, :update, @bucket_id, key_value), key_value: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    # fetch the key value and assert it
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    key_value = nil # insert empty key value
    conn = put conn, bucket_key_value_path(conn, :update, @bucket_id, key_value), key_value: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    key_value = nil #insert key value
    conn = delete conn, bucket_key_value_path(conn, :delete, @bucket_id, key_value)
    assert response(conn, 204)
    # assert that key_value.id is  not present
  end
end
