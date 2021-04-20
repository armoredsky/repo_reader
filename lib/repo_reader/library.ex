defmodule RepoReader.Library do
  alias RepoReader.{FileReader, FlatFiles, JSParser}

  def read(path) do
    FileReader.read(path)
  end

  def list_files( path) do
    FlatFiles.list_all(path)
  end

  def read_repo(path) do
    JSParser.parse_js_repo(path)
  end
end
