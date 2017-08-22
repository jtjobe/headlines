defmodule HeadlinesTest do
  use ExUnit.Case
  doctest Headlines

  test "greets the world" do
    assert Headlines.hello() == :world
  end
end
