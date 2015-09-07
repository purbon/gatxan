require "gatxan/commands/command"

module Gatxan
  module Github
    module Commands

      class List < Command

        def self.run(organization)
          cmd = self.new
          cmd.repositories(organization).each do |repository|
            puts repository
          end
        end

        def repositories(organization)
          GithubCI::Client.repositories(organization)
        end
      end
    end
  end
end
