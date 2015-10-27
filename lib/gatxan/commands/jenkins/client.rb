require 'nokogiri'
require 'jenkins_api_client'

module JenkinsCI
  class Client

    attr_reader :client

    def initialize(config)
      @config = config
      @client = JenkinsApi::Client.new(config)
    end

    def list_jobs(pattern)
      @client.job.list(pattern)
    end

    def disable(job_name)
      @client.job.disable(job_name)
    end

    def enable(job_name)
      @client.job.enable(job_name)
    end

    def add_notification_email(job_name, email)
      puts "Updating #{job_name}"
      params = {:name => job_name, :notification_email => email }
      client.job.add_email_notification(params)
    end

    def create_job(name, config)
      client.job.create(name, config)
    end

    def get_config(job)
      client.job.get_config(job)
    end

    def copy_job(job_name, new_job)
      client.job.copy(job_name, new_job)
    end

    def run_job(job_name, opts={})
      client.job.build(job_name, {}, opts)
    end

    def build_number(job_name)
      client.job.get_current_build_number(job_name)
    end

    def build_details(job_name, build_id)
      client.job.get_build_details(job_name, build_id)
    end

    def change_project_url(doc, project_url)
      puts "Updating the project url #{project_url}"
      urls = doc.xpath("/project/properties/com.coravy.hudson.plugins.github.GithubProjectProperty/projectUrl/text()")
      urls.each do |url|
        url.content = project_url
      end
      doc
    end

    def change_project_name(doc, name)
      urls = doc.xpath("/project/triggers/org.jenkinsci.plugins.ghprb.GhprbTrigger/project/text()")
      urls.each do |url|
        url.content = name
      end
      doc
    end

    def change_git_url(doc, git_url)
      puts "Updating the git URL #{git_url}"
      urls = doc.xpath('/project/scm/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url/text()')
      urls.each do |url|
        url.content = git_url
      end
      doc
    end

    def set_job_scheduler(job_name, timmer)
      puts "Updating #{job_name}"
      config = get_config(job_name)
      xml_doc  = Nokogiri::XML(config)
      add_timer(xml_doc, timmer)
      @client.job.update(job_name, xml_doc.to_s)
    end

    private

    # <hudson.triggers.TimerTrigger>
    # <spec>H * * * *</spec>
    # </hudson.triggers.TimerTrigger>
    def add_timer(docs, pattern)
      triggers = docs.css('triggers').first
      timmer = Nokogiri::XML::Node.new "hudson.triggers.TimerTrigger", docs
      spec   = Nokogiri::XML::Node.new "spec", docs
      spec.content = pattern
      timmer.add_child(spec)
      triggers.add_child(timmer)
    end


  end
end
