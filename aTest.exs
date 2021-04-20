pid = RepoReader.start()
:sys.statistics(pid, true) # turn on collecting process statistics
:sys.trace(pid, true)

# RepoReader.read(pid, "/Users/michaelstreeter/workspaces/logdna-api/internalserver.js")
# |> IO.inspect()

# RepoReader.list_files(pid, "/Users/michaelstreeter/workspaces/logdna-api/")
# |> IO.inspect()
logdna_api_path = "/Users/michaelstreeter/workspaces/logdna-api"
# RepoReader.Library.get_repo_name(logdna_api_path)
# |> IO.inspect()
RepoReader.read_repo(logdna_api_path)
|> IO.inspect()

# Process.sleep(6_000)

# RepoReader.get_state(pid)
# |> IO.inspect()
