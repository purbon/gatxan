module Gatxan
  class Github < ::Thor

    include Thor::Actions

    package_name "github"
    namespace :github

    desc "list [ORGANIZATION]", "List the jobs in a given organization"
    def list(organization="")
      puts "list"
    end

    class << self
      def register_to(klass)
        klass.register(self, :github, "github", "Github related commands")
      end
    end
  end
end
