require "gatxan/commands/command"
require "tmpdir"

module Gatxan
  module Github
    module Commands

      class CommittersReport < Command

        attr_reader :projects, :missing_test

        def initialize
          @client = GithubCI::Client
          @exclude_list = [ "ph", "jsvd", "electrical", "purbon", "colinsurprenant", "suyograo",
                            "talevy", "andrewvc", "jordansissel", "untergeek", "guyboertje" ]
        end

        #https://github.com/logstash-plugins/logstash-input-zeromq.git
        def self.run(projects, options={})
          cmd = self.new
          committers = {}
          acc        = {}
          projects.each do |project|
            repo_name = "logstash-plugins/#{project}"
            puts "processing #{repo_name}"
            committers[project] = cmd.top_committers(repo_name)
            committers[project].each do |committer|
              acc[committer['login']] ||= 0
              acc[committer['login']]  += committer['contributions']
            end
          end
          [ committers, acc ]
        end

        def top_committers(project)
          committers = @client.committers(project).reject do |committer|
            @exclude_list.include?(committer['login'])
          end
          committers
        end
      end
    end
  end
end
