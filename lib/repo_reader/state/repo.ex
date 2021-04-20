defmodule RepoReader.State.Repo do
  defstruct(
    path: "",
    repo_name: "",
    file_list: [],
    parsed_file_list: []
  )
end
