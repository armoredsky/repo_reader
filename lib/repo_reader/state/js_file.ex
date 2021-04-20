defmodule RepoReader.State.JSFile do
  defstruct(
    file_path: "",
    normalized_path: "",
    requires: []
  )
end
