require "gatxan/commands/command"

module Gatxan
  module Jenkins
    module Commands
      class Copy < Command

        def initialize(config)
          @client = JenkinsCI::Client.new(config)
        end

        def run(from, to)
          puts "Copy #{from} to #{to}"
          config = @client.get_config(from)

          puts "Updating the configuration"
          doc  = Nokogiri::XML(config)
          @client.change_git_url(doc, git_pattern(to))
          @client.change_project_name(doc, project_name(to))
          @client.change_project_url(doc, project_url(to))

          puts "Creating the new job"
          @client.create_job(project_name(to), doc.to_xml)
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
