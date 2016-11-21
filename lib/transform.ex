defmodule Transform do
  require HtmlEntities
  require SweetXml
  require Floki
  require IEx

  def map(html, func) do
    xpath_func = fn(string, opts) ->
      SweetXml.xpath(html, SweetXml.sigil_x(to_string(string), to_charlist(opts)))
    end

    func.(xpath_func)
  end

  def clean(html, opts) when is_binary(html) do
    Floki.parse(html)
    |> clean(opts)
  end
  def clean(html, opts \\ []) when is_tuple(html) do
    parse_nodes([html], opts)
  end

  def to_html(parsed) do
    Floki.raw_html(parsed)
  end

  def parse_nodes(nodes, opts) do
    parse_nodes(nodes, parse_format_opts(opts, [:remove_tags, :remove_attrs]), [])
  end
  def parse_nodes([], _opts, acc) do
    acc
  end
  def parse_nodes([text | nodes], opts, acc) when is_binary(text) do
    text_encoded = HtmlEntities.encode(text)
    parse_nodes(nodes, opts, Enum.concat(acc, [text_encoded]))
  end
  def parse_nodes([node = {:comment, _} | nodes], opts, acc) do
    parse_nodes(nodes, opts, acc)
  end
  def parse_nodes([{tag, attrs, children} | nodes], opts, acc) do
    if is_allowed(tag, opts.remove_tags) do
      acc = Enum.concat(acc, [{tag, parse_attrs(attrs, opts), parse_nodes(children, opts, [])}])
    end
    parse_nodes(nodes, opts, acc)
  end

  def parse_attrs(attrs, opts) when is_map(opts) do
    parse_attrs(attrs, opts, [])
  end
  def parse_attrs(attrs, opts \\ []) do
    opts = parse_format_opts(opts, [:remove_attrs])
    parse_attrs(attrs, opts, [])
  end
  def parse_attrs([], _opts, acc) do
    acc
  end
  def parse_attrs([attr = {key, _value} | attrs], opts, acc) do
    if is_allowed(key, opts.remove_attrs) do
      acc = Enum.concat(acc, [attr])
    end
    parse_attrs(attrs, opts, acc)
  end

  def is_allowed(against, funcs) do
    !Enum.any?(funcs, fn(func) -> func.(against) end)
  end

  def parse_format_opts(opts, keys) do
    defaults = Enum.reduce(keys, %{}, fn(key, acc) -> acc = Map.put(acc, key, []) end)
    opts
    |> Enum.into(defaults)
    |> Enum.to_list
    |> Enum.reduce(%{}, fn({key, values}, acc) ->
      acc = Map.put(acc, key, Enum.map(values, &parse_format_opt/1))
    end)
  end

  def parse_format_opt(opt) do
    cond do
      is_function(opt) ->
        opt
      is_binary(opt) ->
        fn(x) -> x == opt end
      Regex.regex?(opt) ->
        fn(x) -> Regex.match?(opt, x) end
    end
  end
end
