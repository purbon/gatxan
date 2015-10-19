require "gatxan/commands/command"
require "tmpdir"

module Gatxan
  module Github
    module Commands

      class DeleteHooks < Command

        def initialize
          @debug        = false
        end

        #https://github.com/logstash-plugins/logstash-input-zeromq.git
        def self.run(repos, options={})
          cmd = self.new
          filter(repos).each do |repo, hooks|
            cmd.delete_hooks(repo, hooks, options[:force])
          end
        end

        def self.filter(repos)
          repos.select do |repo, hooks|
            !repo.include?("example")
          end
        end

        def delete_hooks(repo, hooks, force=false)
         shell = Thor::Shell::Basic.new
          hooks.each do |hook|
            if force || (!force && shell.yes?("Going to delete hook=#{hook['name']} from repo=#{repo}, wanna continue?"))
             puts "deleting #{hook}"
             GithubCI::Client.delete_hook(repo, hook, force)
            end
          end
        end

      end
    end
  end
end
