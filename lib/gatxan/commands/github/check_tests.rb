require "gatxan/commands/command"
require "tmpdir"

module Gatxan
  module Github
    module Commands

      class CheckTests < Command

        attr_reader :projects, :missing_test

        def initialize
          @missing_test = []
          @projects     = []
          @debug        = false
        end

        #https://github.com/logstash-plugins/logstash-input-zeromq.git
        def self.run(repo_urls, options={})
          base_dir = File.join(Dir.tmpdir, 'repos')
          cmd = self.new
          puts "Downloading the repositories at #{base_dir}"
          filter(repo_urls).each do |repo_url|
            cmd.fetch_content(base_dir, repo_url, options[:force])
          end
          puts "Checking tests"
          cmd.check_tests
          cmd.print_results
        end

        def self.filter(repos)
          repos.select do |repo|
            !repo.include?("example")
          end
        end

        def print_results
          puts missing_test.map { |v| v[:name]}
          puts missing_test.count
        end

        def check_tests
          @missing_test = []
          @projects.each do |project|
            if has_content?(project) && !has_test_or_specs(project)
              name = parse_package_name(project)
              missing_test << { :name => name }
            end
          end
        end

        def fetch_content(base_dir, repo_url, force=false)
          name = repo_url.split("/").last[0..-5]
          projects << GithubCI::Client.fetch_repo(base_dir, name, repo_url, force)
        end

        def has_content?(path)
          !Dir.glob("#{path}/lib*").empty?
        end

        def has_test_or_specs(path)
          #vendor/bundle/jruby/1.9/gems/logstash-codec-json-0.1.5
          entries = Dir.glob("#{path}/spec*")
          return false if entries.empty?
          specs   = Dir.glob("#{path}/spec*/**/*_spec.rb")
          return false if specs.empty?
          nearly_empty_specs = 0
          data = []
          specs.each do |spec|
            lines = File.readlines(spec)
            if lines.count < 20
              if !lines.join(' ').match(/it|insist|expect/)
                data << {:spec => spec, :lines => lines}
                nearly_empty_specs += 1
              end
            end
          end
          if nearly_empty_specs > 0
            puts path
            data.each do |r|
              puts r[:spec]
              puts r[:lines]
              puts
            end
          end if @debug
          nearly_empty_specs == 0
        end

        def parse_package_name(package)
          #vendor/bundle/jruby/1.9/gems/logstash-codec-json
          package.split("/").last
        end

      end
    end
  end
end
