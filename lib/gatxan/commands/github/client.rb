require "octokit"
require 'git'
require "fileutils"
require "time"

module GithubCI
  class Client

    EXCLUDED_USERS = [ "ycombinator", "ph", "jsvd", "electrical", "coolacid", "tbragin", "purbon", "colinsurprenant", "suyograo", "talevy",
                       "andrewvc", "jordansissel", "untergeek", "guyboertje", "Paul Echeverri" ]

    def self.dump_commits(repo, &block)
      Octokit.auto_paginate = true
      valid_paths = [ "lib/logstash/inputs/*", "lib/logstash/fitlers/*", "lib/logstash/codecs/*", "lib/logstash/outputs/*" ]
      since = (Time.now-(18*30*86400)).iso8601
      Octokit.commits(repo, "master").map do |commit|
        begin
          hash   = commit.to_hash
          sha    = hash[:sha]
          author = hash[:author][:login] rescue hash[:commit][:author][:name]
          date   = hash[:commit][:author][:date]
          next if EXCLUDED_USERS.include?(author)
          details = Octokit.commit(repo, sha).to_hash
          files   = details[:files].select do |file|
            valid_paths.any? { |pattern| file[:filename] =~ /^#{pattern}/ }
          end
          next if files.empty?
          print "."
          block.call({sha: sha, author: author, date: date, details: files.map { |file| file[:filename] } })
        rescue => e
          puts e
        end
      end.compact
    end

    def self.delete_hook(repo, hook, force)
      Octokit.client.remove_hook(repo, hook["id"])
    end

    def self.fetch_hooks(name, force)
      Octokit.client.hooks(name).map do |hook|
        { "id" => hook["id"], "name" => hook["name"], "url" => hook["config"]["url"] }
      end
    end

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
