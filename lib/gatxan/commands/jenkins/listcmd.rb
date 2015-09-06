require "gatxan/commands/command"

module Gatxan
  module Jenkins
    module Commands

      class List < Command

        def initialize(config)
          @client = JenkinsCI::Client.new(config)
        end

        def self.run(pattern, config)
          cmd = self.new(config)
          cmd.each_job(pattern) do |job|
            puts job
          end
        end

        def each_job(pattern, &block)
          @client.list_jobs(pattern).each(&block)
        end

      end

    end
  end
end
