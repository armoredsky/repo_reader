defmodule RepoReader.JSParser do
  alias RepoReader.{FileReader, FlatFiles}
  alias RepoReader.State.{JSFile, Repo}

  def parse_js_repo(path) do
    %Repo{path: path}
    |> build_file_list()
    |> get_repo_name()
    |> parse_file_list()
  end

  defp build_file_list(repo_state) do
    Map.put(repo_state, :file_list, FlatFiles.list_all(repo_state.path) |> filter_file_list)
  end

  defp filter_file_list(list) do
    Enum.filter(list, &(not String.contains?(&1, "test")))
    |> Enum.filter(&(not String.contains?(&1, "Test")))
    |> Enum.filter(&(not String.contains?(&1, "/coverage/")))
    |> Enum.filter(&(not String.contains?(&1, "/__mocks__/")))
    |> Enum.filter(&(not String.contains?(&1, "/bundle/")))
    # |> Enum.filter(&String.contains?(&1, "aggrega"))
  end

  def get_repo_name(repo_state) do
    Map.put(
      repo_state,
      :repo_name,
      String.split(repo_state.path, "/")
      |> List.last()
    )
  end

  def parse_file_list(repo_state), do: parse_file_list(repo_state, repo_state.file_list)
  def parse_file_list(repo_state, _file_list = []), do: repo_state

  def parse_file_list(repo_state, file_list) do
    [path | file_list] = file_list

    cond do
      String.ends_with?(path, ".js") ->
        repo_state
        |> parse_js_file(path)
        |> parse_file_list(file_list)

      true ->
        parse_file_list(repo_state, file_list)
    end
  end

  defp parse_js_file(repo_state, path) do
    file_state = %JSFile{file_path: path, normalized_path: normalize_file_path(repo_state, path)}

    parsed_file =
      FileReader.read(path)
      |> build_required(repo_state, file_state)

    %{repo_state | parsed_file_list: [parsed_file] ++ repo_state.parsed_file_list}
  end

  def normalize_file_path(repo_state, path) do
    String.split(path, repo_state.path)
    |> List.last()
  end

  defp build_required(_line_list = [], _repo_state, file_state), do: file_state

  defp build_required(line_list, repo_state, file_state) do
    [line | tail] = line_list

    requires = Map.get(file_state, :requires)

    new_required = grab_require_path(repo_state, line, file_state)

    file_state = Map.put(file_state, :requires, new_required ++ requires)

    build_required(tail, repo_state, file_state)
  end

  defp grab_require_path(repo_state, line, file_state) do
    require_regex = ~r/require\(['"]([^'"]+?)?['"]/

    Regex.run(require_regex, line)
    |> grab_require_match()
    |> fix_relative_paths(repo_state, file_state.file_path)
  end

  defp grab_require_match(_maybe_match = nil), do: []
  defp grab_require_match(maybe_match), do: [List.last(maybe_match)]

  defp fix_relative_paths(required_list, repo_state, file_path),
    do: fix_relative_paths(required_list, repo_state, file_path, [])

  defp fix_relative_paths(_required_list = [], _repo_state, _file_path, fixed_required_list),
    do: fixed_required_list

  defp fix_relative_paths(required_list, repo_state, file_path, fixed_required_list) do
    [head | tail] = required_list

    cond do
      String.contains?(head, "../") ->
        new = fix_double_dot_path(repo_state, head, file_path)
        new_fixed_list = [new] ++ fixed_required_list

        fix_relative_paths(
          tail,
          repo_state,
          file_path,
          new_fixed_list
        )

      String.contains?(head, "./") ->
        fix_relative_paths(
          tail,
          repo_state,
          file_path,
          [fix_dot_path(repo_state, head, file_path)] ++ fixed_required_list
        )

      true ->
        fix_relative_paths(tail, repo_state, file_path, fixed_required_list)
    end
  end

  defp fix_double_dot_path(repo_state, required, file_path) do
    file_path_list = String.split(file_path, "/")
    required_path_list = String.split(required, "/")
    double_dot_count = Enum.count(required_path_list, &(&1 == ".."))

    # 1 for the file name in the path
    file_path_list =
      Enum.slice(file_path_list, 0, Enum.count(file_path_list) - double_dot_count - 1)

    required_path_list =
      Enum.filter(required_path_list, &(&1 != ".."))
      |> Enum.filter(&(&1 != "."))

    real_path = Enum.join(file_path_list ++ required_path_list, "/")
    real_path = fix_index(repo_state, real_path)
    normalize_file_path(repo_state, real_path)
  end

  defp fix_dot_path(repo_state, required, file_path) do
    file_path_list = String.split(file_path, "/")
    file_path_list = Enum.slice(file_path_list, 0, Enum.count(file_path_list) - 1)
    real_path = Enum.join(file_path_list ++ [String.replace(required, "./", "")], "/")
    real_path = fix_index(repo_state, real_path)
    normalize_file_path(repo_state, real_path)
  end

  defp fix_index(repo_state, path) do
    fixed_path = path <> "/index.js"

    cond do
      Enum.any?(repo_state.file_list, fn a_path -> String.contains?(a_path, fixed_path) end) ->
        fixed_path

      not String.contains?(path, ".js") ->
        path <> ".js"

      true ->
        path
    end
  end
end
