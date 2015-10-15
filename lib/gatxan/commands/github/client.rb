require "octokit"
require 'git'
require "fileutils"

module GithubCI
  class Client

    def self.committers(repo)
      Octokit.contributors(repo).map do |user|
        { 'login' => user['login'], 'contributions' => user['contributions'] }
      end
    end

    def self.repositories(organization)
      Octokit.auto_paginate = true
      repo_list = Octokit.organization_repositories(organization)
      repo_list.map { |r| r.name }
    end

    def self.issues(repo)
      Octokit.auto_paginate = true
      Octokit.issues(repo)
    end

    def self.fetch_repo(base_dir, name, repo_url, force)
      path = File.join(base_dir, name)
      FileUtils.rm_rf(path) if force
      if !Dir.exist?(path)
        puts "Fetching #{repo_url}"
        Git.clone(repo_url, name, :path => base_dir)
      end
      path
    end
  end
end
