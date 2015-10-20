require "gatxan/commands/command"
require "tmpdir"

module Gatxan
  module Github
    module Commands

      class UpdateHooks < Command

        def initialize
          @debug        = false
        end

        #https://github.com/logstash-plugins/logstash-input-zeromq.git
        def self.run(repos, config, options={})
          cmd = self.new
          filter(repos).each do |repo, hooks|
            cmd.update_hooks(repo, hooks, config, options[:force])
          end
        end

        def self.filter(repos)
          repos.select do |repo, hooks|
            !repo.include?("example")
          end
        end

        def update_hooks(repo, hooks, config, force=false)
         shell = Thor::Shell::Basic.new
          hooks.each do |hook|
            if force || (!force && shell.yes?("Going to update hook=#{hook['name']} from repo=#{repo}, wanna continue?"))
             puts "updating #{hook}"
             GithubCI::Client.update_hook(repo, hook, config, force)
            end
          end
        end

      end
    end
  end
end
