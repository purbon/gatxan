require "thor"
require "gatxan/configuration"
require "gatxan/commands/jenkins"
require "gatxan/commands/github"
require "csv"

module Gatxan
  class CLI < ::Thor

    include ::Thor::Actions

    def self.start(*)
      super
    end

    desc "list_jobs [PATTERN]", "List available jobs in your configured Jenkins instance"
    def list_jobs(pattern="")
      Jenkins::Commands::List.run(pattern, Gatxan::Configuration.load_jenkins_config(destination_root))
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

    desc "issues_stats [ORGANIZATION]", "Give you some stats about issues in your organization repositories"
    method_options :to_csv => :boolean
    def issues_stats(organization="")
      Gatxan::Configuration.configure_github(destination_root)
      org_stats = Github::Commands::Stats.run(organization)
      if options.to_csv?
        CSV.open(File.join(destination_root, "issues_stats.csv"), "wb") do |file|
          headers = true
          org_stats.each do |project_stats|
            file << project_stats.keys if headers
            file << project_stats.values
            headers = false
          end
        end
      else
        puts org_stats
      end
    end

  end
end
