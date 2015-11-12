defmodule KvApi.KeyValueView do
  use KvApi.Web, :view

  def render("show.json", %{key_value: key_value}) do
    %{data: render_one(key_value, KvApi.KeyValueView, "key_value.json")}
  end

  def render("key_value.json", %{key_value: key_value}) do
    %{id: key_value.id,
      key: key_value.key,
      value: key_value.value}
  end
end
