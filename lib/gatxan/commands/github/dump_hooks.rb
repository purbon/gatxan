require "gatxan/commands/command"
require "tmpdir"

module Gatxan
  module Github
    module Commands

      class DumpHooks < Command

        attr_reader :projects, :missing_test

        def initialize
          @missing_test = []
          @projects     = {}
          @debug        = false
        end

        #https://github.com/logstash-plugins/logstash-input-zeromq.git
        def self.run(repo_urls, options={})
          cmd = self.new
          filter(repo_urls).each do |repo_url|
            cmd.fetch_content(repo_url, options[:force])
          end
          cmd.projects
        end

        def self.filter(repos)
          repos.select do |repo|
            !repo.include?("example")
          end
        end

        def fetch_content(repo_url, force=false)
          parts = repo_url.split("/")
          key   = "#{parts[-2]}/#{parts.last[0..-5]}"
          puts key
          projects[key] = GithubCI::Client.fetch_hooks(key, force)
        end

      end
    end
  end
end
