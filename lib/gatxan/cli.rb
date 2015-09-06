require "thor"
require "gatxan/jenkins"
require "gatxan/github"

module Gatxan
  class CLI < ::Thor

    include ::Thor::Actions

    Jenkins.register_to(self)
    Github.register_to(self)

    def self.start(*)
      super
    end

  end
end
