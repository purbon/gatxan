module Gatxan
  class Jenkins < ::Thor

    include Thor::Actions

    package_name "jenkins"
    namespace :jenkins

    desc "list", "List available jobs in your configured Jenkins instance"
    def list
      puts "list"
    end

    desc "create", "Create a new job from scratch"
    def create
      puts "create"
    end

    desc "delete [JOB]", "Delete a given job"
    def delete(job="")
      puts "delete"
    end

    class << self
      def register_to(klass)
        klass.register(self, :jenkins, "jenkins", "Jenkins related commands")
      end
    end
  end
end
