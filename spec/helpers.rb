module Helpers
  def set_branch
    branch = `git branch --list #{TEST_BRANCH}`.chomp
    `git branch #{TEST_BRANCH}` if branch.empty?
    system("git checkout #{TEST_BRANCH}")
    unless $? == 0
      e = "Error checking out #{m[2]}
           there are probably uncommited changes on #{@origin}"
      raise RuntimeError, e
    end
  end
end
