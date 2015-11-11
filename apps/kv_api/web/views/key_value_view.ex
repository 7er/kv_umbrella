defmodule :"Elixir..KeyValue"View do
  use .Web, :view

  def render("index.json", %{key-values: key-values}) do
    %{data: render_many(key-values, :"Elixir..KeyValue"View, "key_value.json")}
  end

  def render("show.json", %{key_value: key_value}) do
    %{data: render_one(key_value, :"Elixir..KeyValue"View, "key_value.json")}
  end

  def render("key_value.json", %{key_value: key_value}) do
    %{id: key_value.id,
      key: key_value.key,
      value: key_value.value}
  end
end
