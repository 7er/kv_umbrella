
defmodule KvApi.BucketControllerTest do
  use KvApi.ConnCase

  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  # test "lists all entries on index", %{conn: conn} do
  #   conn = get conn, bucket_path(conn, :index)
  #   assert json_response(conn, 200)["data"] == []
  # end

  # test "shows chosen resource", %{conn: conn} do
  #   bucket = Repo.insert! %Bucket{}
  #   conn = get conn, bucket_path(conn, :show, bucket)
  #   assert json_response(conn, 200)["data"] == %{"id" => bucket.id,
  #     "name" => bucket.name}
  # end

  # test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
  #   assert_raise Ecto.NoResultsError, fn ->
  #     get conn, bucket_path(conn, :show, -1)
  #   end
  # end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, bucket_path(conn, :create), bucket: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Bucket, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, bucket_path(conn, :create), bucket: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

end
