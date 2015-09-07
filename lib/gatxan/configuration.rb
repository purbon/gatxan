require "yaml"

module Gatxan
  module Configuration

    def self.load_jenkins_config(root)
      file_path = ::File.expand_path ::File.join(root, ".jenkins.config.yml")
      @@config ||= ::YAML.load_file(file_path)
    end

    def self.configure_github(root)
      file_path = ::File.expand_path ::File.join(root, ".github.config.yml")
      return false unless File.exist?(file_path)
      config    = ::YAML.load_file(file_path)
      Octokit.configure do |c|
        c.login    = config[:username]
        c.password = config[:password]
      end
    end
  end
end
