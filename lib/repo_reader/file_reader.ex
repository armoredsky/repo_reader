defmodule RepoReader.FileReader do
  def read(path) do
    read_file(path)
    |> split_file()
  end

  defp read_file(path) do
    {:ok, content} = File.read(path)
    content
  end

  defp split_file(content) do
    content
    |> String.split("\n", trim: true)
  end
end
