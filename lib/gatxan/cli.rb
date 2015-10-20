require "thor"
require "gatxan/configuration"
require "gatxan/commands/jenkins"
require "gatxan/commands/github"
require "csv"
require "json"

module Gatxan
  class CLI < ::Thor

    include ::Thor::Actions

    def self.start(*)
      super
    end

    ##
    # Jenkins related commands
    ##
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

    desc "check_tests", "Build a report about test quality metrics"
    method_option :repos, :type => :array, :required => true
    method_options :force => :boolean
    def check_tests
      cli_options = { :force => options.force? }
      Github::Commands::CheckTests.run(options.repos, cli_options)
    end

    desc "dump_hooks", "Dump all installed hooks for a list of repos"
    method_option :repos, :type => :array, :required => true
    method_options :force => :boolean
    def dump_hooks
      Gatxan::Configuration.configure_github(destination_root)
      cli_options = { :force => options.force? }
      hooks = Github::Commands::DumpHooks.run(options.repos, cli_options)
      File.open("hooks.json", 'w') { |file| file.write(hooks.to_json) }
    end

    desc "delete_hooks", "Delete a list of hooks"
    method_option :hooks, :type => :string, :required => true
    method_options :force => :boolean
    def delete_hooks
      Gatxan::Configuration.configure_github(destination_root)
      cli_options = { :force => options.force? }
      hooks       = JSON.parse(File.read(options.hooks))
      Github::Commands::DeleteHooks.run(hooks, cli_options)
    end

    desc "update_hooks", "Update a list of hooks with a given configuration"
    method_option :hooks,  :type => :string, :required => true
    method_option :config, :type => :string, :required => true
    method_options :force => :boolean
    def update_hooks
      Gatxan::Configuration.configure_github(destination_root)
      cli_options = { :force => options.force? }
      hooks       = JSON.parse(File.read(options.hooks))
      config      = JSON.parse(File.read(options.config))
      Github::Commands::UpdateHooks.run(hooks, config, cli_options)
    end

    desc "find_committers", "Build a report on contributtors"
    method_option :repos, :type => :array, :required => true
    method_options :force => :boolean
    def find_committers
      Gatxan::Configuration.configure_github(destination_root)
      cli_options = { :force => options.force? }
      committers, accumulated = Github::Commands::CommittersReport.run(options.repos, cli_options)
      accumulated.reject! do |user, acc|
        acc < 5
      end
      File.open("commiters.json", 'w') { |file| file.write(committers.to_json) }
      File.open("accumulated.json", 'w') { |file| file.write(accumulated.to_json) }
    end

    desc "dump_commits", "dump commits from a given repository"
    method_option :repo, :type => :string, :required => true
    method_options :force => :boolean
    def dump_commits
      Gatxan::Configuration.configure_github(destination_root)
      cli_options = { :force => options.force? }
      File.open("commits.json", "w") do |file|
        events = {}
        Github::Commands::DumpCommits.run(options.repo, cli_options) do |event|
          event[:details].each do |detail|
            events[detail] ||= {}
            next if !events[detail][:date].nil? && events[detail][:date] < event[:date]
            puts event
            events[detail][:date]   = event[:date]
            events[detail][:author] = event[:author]
          end
        end
        file.write(events.to_json)
      end
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
