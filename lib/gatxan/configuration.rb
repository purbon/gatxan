require "yaml"

module Gatxan
  module Configuration

    def self.load(root)
      file_path = ::File.expand_path ::File.join(root, ".jenkins.config.yaml")
      @@config ||= ::YAML.load_file(file_path)
    end

  end
end
