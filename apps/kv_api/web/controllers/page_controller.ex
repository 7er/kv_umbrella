defmodule KvApi.PageController do
  use KvApi.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
