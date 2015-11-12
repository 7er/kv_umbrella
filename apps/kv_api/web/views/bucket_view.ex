defmodule KvApi.BucketView do
  use KvApi.Web, :view

  def render("index.json", %{buckets: buckets}) do
    %{data: render_many(buckets, KvApi.BucketView, "bucket.json")}
  end

  def render("show.json", %{bucket: bucket}) do
    %{data: render_one(bucket, KvApi.BucketView, "bucket.json")}
  end

  def render("bucket.json", %{bucket: bucket}) do
    %{id: bucket.id}
  end
end
