defmodule KvApi.BucketController do
  use KvApi.Web, :controller

  alias KvApi.Bucket

  plug :scrub_params, "bucket" when action in [:create, :update]

  def index(conn, _params) do
    buckets = Repo.all(Bucket)
    render(conn, "index.json", buckets: buckets)
  end

  def create(conn, %{"bucket" => bucket_params}) do
    changeset = Bucket.changeset(%Bucket{}, bucket_params)

    case Repo.insert(changeset) do
      {:ok, bucket} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", bucket_path(conn, :show, bucket))
        |> render("show.json", bucket: bucket)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(KvApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    bucket = Repo.get!(Bucket, id)
    render(conn, "show.json", bucket: bucket)
  end

  def update(conn, %{"id" => id, "bucket" => bucket_params}) do
    bucket = Repo.get!(Bucket, id)
    changeset = Bucket.changeset(bucket, bucket_params)

    case Repo.update(changeset) do
      {:ok, bucket} ->
        render(conn, "show.json", bucket: bucket)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(KvApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    bucket = Repo.get!(Bucket, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(bucket)

    send_resp(conn, :no_content, "")
  end
end
