require "octokit"

module GithubCI
  class Client

    def self.repositories(organization)
      Octokit.auto_paginate = true
      repo_list = Octokit.organization_repositories(organization)
      repo_list.map { |r| r.name }
    end
  end
end
