require "thor"
require "gatxan/configuration"
require "gatxan/commands/jenkins"
require "gatxan/commands/github"

module Gatxan
  class CLI < ::Thor

    include ::Thor::Actions

    def self.start(*)
      super
    end

    desc "list_jobs [PATTERN]", "List available jobs in your configured Jenkins instance"
    def list_jobs(pattern="")
      Jenkins::Commands::List.run(pattern, Gatxan::Configuration.load(destination_root))
    end

    desc "create_job", "Create a new job from scratch"
    def create_job
      raise Exception.new("Not yet implemented!")
    end

    desc "delete_job [JOB]", "Delete a given job"
    def delete_job(job="")
      raise Exception.new("Not yet implemented!")
    end

    ##
    # Github related commands
    ##
    desc "list_repos [ORGANIZATION]", "List the repositories in a given organization"
    def list_repos(organization="")
      Github::Commands::List.run(organization)
    end
  end
end
