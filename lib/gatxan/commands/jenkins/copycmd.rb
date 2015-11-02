require "gatxan/commands/command"

module Gatxan
  module Jenkins
    module Commands
      class Copy < Command

        def initialize(config)
          @client = JenkinsCI::Client.new(config)
        end

        def run(from, to_jobs)
          config = @client.get_config(from)
          to_jobs.each do |job|
            puts "Copy #{from} to #{job}"
            puts "Updating the configuration"
            doc  = Nokogiri::XML(config.clone)
            @client.change_git_url(doc, git_pattern(job))
            @client.change_project_name(doc, project_name(job))
            @client.change_project_url(doc, project_url(job))

            puts "Creating the new job #{job}"
            @client.create_job(project_name(job), doc.to_xml)
          end
        end

        private

        def project_url(to)
          "https://github.com/logstash-plugins/#{to}/"
        end

        def git_pattern(to)
          "git@github.com:logstash-plugins/#{to}.git"
        end

        def project_name(to)
          parts = to.split("-")
          "logstash-plugin-#{parts[1]}-#{parts[2]}_PR"
        end

      end

    end
  end
end
