defmodule RepoReader.Server do
  use GenServer
  alias RepoReader.Library

  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  def init(_) do
    {:ok, %{}}
  end

  def handle_call({:read, path}, _from, state) do
    string_list = Library.read(path)
    {:reply, string_list, state}
  end
  def handle_call({:list_files, path}, _from, state) do
    file_list = Library.list_files(path)
    {:reply, file_list, state}
  end
  def handle_call({:state}, _from, state) do
    {:reply, state, state}
  end
  def handle_call(_call, _from, state) do
    {:reply, "That call is not supported", state}
  end

  def handle_cast({:read_repo, path}, state) do
    new_state = Library.read_repo(path)
    {:noreply, Map.put(state, path, new_state)}
  end
end
