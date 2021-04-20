defmodule RepoReader do
  alias RepoReader.{Server, Library}
  def start do
    {:ok, pid} = Server.start_link()
    pid
  end

  def read(path) do
    Library.read(path)
  end
  def read(pid, path) do
    GenServer.call(pid, {:read, path})
  end

  def list_files(path) do
    Library.list_files(path)
  end
  def list_files(pid, path) do
    GenServer.call(pid, {:list_files, path})
  end

  def read_repo(path) do
    Library.read_repo( path)
  end
  def read_repo(pid, path) do
    GenServer.cast(pid, {:read_repo, path})
  end

  def get_state(pid) do
    GenServer.call(pid, {:state})
  end
end
