module GitAPI

  def create_git_project
    run_simple "git init"
    run_simple "git add ."
    run_simple "git commit -m 'First commit'"
  end
end
World(GitAPI)
