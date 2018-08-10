# frozen_string_literal: true

module Specify
  module CLI
    def self.configure_database(config)
      STDERR.puts "Configuring new database: #{config.database}"
      config.user_name = require_input 'MySQL user name'
      config.user_password = require_input 'password (blank for prompt)'
      config.session_user = require_input 'Specify user (leave blank to skip)'
      config.save
    end

    def self.configure_host(config)
      return unless proceed? "host #{config.host} not known"
      config.port = require_input 'port number (leave blank for default)'
      config.save
    end

    def self.db_config?
      File.exist?(DATABASES)
    end

    def self.db_config!(file, global_options)
      return if db_config? && !global_options[:db_config]
      STDERR.puts "Creating new config file #{file}"
      Specify::Configuration::Config.empty file do |config|
        config.add_host global_options[:host], global_options[:port]
      end
    end

    def self.proceed?(message)
      STDERR.puts message
      STDERR.print "Configure? (Y/n)"
      return true if /^[Yy](es)?/.match Readline.readline(': ')
    end

    def self.require_input(message)
      STDERR.print message
      answer = Readline.readline(': ')
      return if answer.empty?
      answer
    end
  end
end
