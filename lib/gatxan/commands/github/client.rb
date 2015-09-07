require "octokit"

module GithubCI
  class Client

    def self.repositories(organization)
      Octokit.auto_paginate = true
      repo_list = Octokit.organization_repositories(organization)
      repo_list.map { |r| r.name }
    end

    def self.issues(repo)
      Octokit.auto_paginate = true
      Octokit.issues(repo)
    end
  end
end
