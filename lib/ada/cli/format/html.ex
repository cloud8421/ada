defmodule Ada.CLI.Format.HTML do
  @moduledoc """
  Experimental shell-based HTML renderer.
  """

  alias Ada.CLI.Markup

  @doc """
  Prints an html tree (as specified in `t:Floki.html_tree/0`) as
  an io list (with colors).
  """
  @spec pp(Floki.html_tree() | String.t()) :: [binary]
  def pp(nodes) when is_list(nodes), do: Enum.map(nodes, &pp/1)
  def pp(text) when is_binary(text), do: text

  def pp({tag, _attrs, child_nodes})
      when tag in ["b", "strong"] do
    [Markup.primary(pp(child_nodes))]
  end

  def pp({tag, _attrs, child_nodes})
      when tag in ["em", "i"] do
    [Markup.secondary(pp(child_nodes))]
  end

  def pp({tag, _attrs, child_nodes})
      when tag in ["h1", "h2", "h3"] do
    Markup.h1(pp(child_nodes))
  end

  def pp({"p", _attrs, child_nodes}) do
    [Markup.p(IO.iodata_to_binary(pp(child_nodes)), 72)]
  end

  def pp({tag, _attrs, _child_nodes})
      when tag in ["figure", "br", "aside", "blockquote"] do
    []
  end

  def pp({"ul", _attrs, child_nodes}) do
    Enum.map(child_nodes, fn child_node ->
      content = Markup.wrap(IO.iodata_to_binary(pp(child_node)), 72)
      [Markup.left_pad(), Markup.dash(), content]
    end)
  end

  def pp({"a", _attrs, child_nodes} = el) do
    case Floki.attribute(el, "a", "href") do
      [href] -> Markup.tertiary(href)
      [] -> pp(child_nodes)
    end
  end

  def pp({_tag, _attrs, child_nodes}) do
    pp(child_nodes)
  end
end
