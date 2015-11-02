require "gatxan/commands/command"

module Gatxan
  module Jenkins
    module Commands

      class Delete < Command

        def initialize(config)
          @client = JenkinsCI::Client.new(config)
        end

        def self.run(pattern, config)
          cmd = self.new(config)
          cmd.each_job(pattern) do |job|
            puts "Delete #{job}"
            cmd.delete(job)
          end
        end

        def each_job(pattern, &block)
          @client.list_jobs(pattern).each(&block)
        end

        def delete(job)
          @client.delete_job(job)
        end

      end

    end
  end
end
