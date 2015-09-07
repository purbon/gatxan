require "gatxan/commands/command"
require "time"

module Gatxan
  module Github
    module Commands

      class Stats < Command

        def initialize
          @client = GithubCI::Client
        end

        def self.run(organization)
          cmd   = self.new
          now   = Time.now.utc
          stats  = []
          cmd.repositories(organization).each do |project|
            full_repo_name = "#{organization}/#{project}"
            project_stats  = { project: full_repo_name, open_issues: 0, open_prs: 0,  comments: 0, issues_1w: 0, issues_1m: 0, issues_2m: 0, issues_older: 0, not_labeled: 0}
            cmd.fetch_issues_for(full_repo_name).each do |issue|
              project_stats[:open_issues] += 1

              age_tag = cmd.tag_age_of(issue, now)
              project_stats[age_tag] += 1
              project_stats[:not_labeled] += 1 if issue[:labels].empty?
              project_stats[:open_prs] += 1    if issue[:pull_request]
              project_stats[:comments] += issue[:comments]
            end
            project_stats[:comments] = project_stats[:comments].to_i / project_stats[:open_issues].to_f
            project_stats[:open_issues] -= project_stats[:open_prs]
            stats << project_stats
          end
          stats
        end

        def repositories(organization)
          @client.repositories(organization)
        end

        def fetch_issues_for(repo, &block)
          @client.issues(repo).each(&block)
        end

        def tag_age_of(issue, now)
          tag = :issues_older
          tag = :issues_1w if (issue[:created_at] >= now-7.days)
          tag = :issues_1m if (issue[:created_at] < now-7.days && issue[:created_at] >= now-30.days)
          tag = :issues_2m if (issue[:created_at] < now-30.days && issue[:created_at] >= now-60.days)
          return tag
        end

      end
    end
  end
end
