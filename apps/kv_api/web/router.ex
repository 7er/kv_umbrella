defmodule KvApi.Router do
  use KvApi.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", KvApi do
    pipe_through :api
    resources "/buckets", BucketController, only: [:create] do
      resources "key-values", KeyValueController, :except: [:new, :edit]
    end
  end
end
