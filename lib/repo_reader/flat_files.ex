defmodule RepoReader.FlatFiles do
  def list_all(filepath) do
    cond do
      String.contains?(filepath, ".git") -> []
      String.contains?(filepath, "/node_modules/") -> []

      true -> expand(File.ls(filepath), filepath)
    end
  end

  defp expand({:ok, files}, path) do
    files
    |> Enum.flat_map(&list_all("#{path}/#{&1}"))
  end

  defp expand({:error, _}, path) do
    [path]
  end
end
