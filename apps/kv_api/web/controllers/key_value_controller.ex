defmodule KvApi.KeyValueController do
  use KvApi.Web, :controller

  plug :scrub_params, "key_value" when action in [:create, :update]

  def create(conn, %{"bucket_id" => bucket_id, "key_value" => key_value_params}) do
    changeset = nil
    case Repo.insert(changeset) do
      {:ok, key_value} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", bucket_key_value_path(conn, :show, key_value))
        |> render("show.json", key_value: key_value_params)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(KvApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    key_value = nil
    render(conn, "show.json", key_value: key_value)
  end

  def update(conn, %{"id" => id, "key_value" => key_value_params}) do
    changeset = nil
    case Repo.update(changeset) do
      {:ok, key_value} ->
        render(conn, "show.json", key_value: key_value)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(KvApi.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).

    # delete key value pair here
    send_resp(conn, :no_content, "")
  end
end
