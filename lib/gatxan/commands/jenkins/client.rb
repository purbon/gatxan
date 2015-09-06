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

    def run_job(job_name, opts={})
      client.job.build(job_name, {}, opts)
    end

    def build_number(job_name)
      client.job.get_current_build_number(job_name)
    end

    def build_details(job_name, build_id)
      client.job.get_build_details(job_name, build_id)
    end

    def set_job_scheduler(job_name, timmer)
      puts "Updating #{job_name}"
      config = client.job.get_config(job_name)
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
