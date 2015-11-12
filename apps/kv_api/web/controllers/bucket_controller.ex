defmodule KvApi.BucketController do
  use KvApi.Web, :controller

  alias KvApi.Bucket

  plug :scrub_params, "bucket" when action in [:create, :update]

  def create(conn, %{"bucket" => bucket_params}) do
    KV.Registry.create(KV.Registry, bucket_params["id"])
    bucket_struct = %Bucket{id: bucket_params["id"]}
    case :ok do
      :ok ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", bucket_path(conn, :show, bucket_struct))
        |> render("show.json", bucket: bucket_struct)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(KvApi.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
