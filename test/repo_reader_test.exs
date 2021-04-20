defmodule RepoReaderTest do
  use ExUnit.Case
  doctest RepoReader

  test "greets the world" do
    assert RepoReader.hello() == :world
  end
end
