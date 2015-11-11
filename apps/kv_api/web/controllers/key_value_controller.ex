defmodule :"Elixir..KeyValue"Controller do
  use .Web, :controller

  alias :"Elixir..KeyValue"

  plug :scrub_params, "key_value" when action in [:create, :update]

  def index(conn, _params) do
    key-values = Repo.all(KeyValue")
    render(conn, "index.json", key-values: key-values)
  end

  def create(conn, %{"key_value" => key_value_params}) do
    changeset = KeyValue".changeset(%KeyValue"{}, key_value_params)

    case Repo.insert(changeset) do
      {:ok, key_value} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", key_value_path(conn, :show, key_value))
        |> render("show.json", key_value: key_value)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    key_value = Repo.get!(KeyValue", id)
    render(conn, "show.json", key_value: key_value)
  end

  def update(conn, %{"id" => id, "key_value" => key_value_params}) do
    key_value = Repo.get!(KeyValue", id)
    changeset = KeyValue".changeset(key_value, key_value_params)

    case Repo.update(changeset) do
      {:ok, key_value} ->
        render(conn, "show.json", key_value: key_value)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    key_value = Repo.get!(KeyValue", id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(key_value)

    send_resp(conn, :no_content, "")
  end
end
