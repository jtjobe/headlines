defmodule HeadlinesTest do
  use ExUnit.Case
  doctest Headlines
  alias Headlines, as: H

  def normalize_to_list(raw_data) do

    data = if is_tuple(raw_data), do: Tuple.to_list(raw_data), else: raw_data

    Enum.reduce(data, [], fn(x, acc) ->

      if is_binary(x) do
        [x | acc]
      else
        t = Enum.reduce(x, [], fn(y, acc) ->
          if is_tuple(y), do: [ Tuple.to_list(y) | acc], else: [ y | acc ]
        end)

        [t | acc]
      end
    end) |> List.flatten
  end

  test "all_to_list" do
    raw_data = {"a", [{"href", "http://www.nytimes.com/content/help/site/ie9-support.html"}, {"class", "action-link"}], ["LEARN MORE »"]}
    result = normalize_to_list(raw_data)

    # IO.puts "ALL"
    # IO.inspect Util.typeof(result)
    # IO.inspect result
    # IO.puts ""

    # IO.puts "ELEMENTS"
    # Enum.each(result, fn(x) ->
    #   IO.inspect Util.typeof(x)
    #   IO.inspect x
    #   IO.puts ""
    # end)

    assert result == ["LEARN MORE »", "class", "action-link", "href",
             "http://www.nytimes.com/content/help/site/ie9-support.html", "a"]
  end
end
