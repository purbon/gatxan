require "gatxan/commands/command"

module Gatxan
  module Github
    module Commands

      class DumpCommits < Command

        def self.run(project, options={}, &block)
          cmd = self.new
          cmd.dump_commits(project, &block)
        end

        def dump_commits(organization, &block)
          GithubCI::Client.dump_commits(organization, &block)
        end
      end
    end
  end
end
