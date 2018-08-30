# frozen_string_literal: true

module Specify
  module CLI
    # Asks the user to configure a database.
    def self.configure_database(config)
      STDERR.puts "Configuring new database: #{config.database}"
      config.user_name = require_input 'MySQL user name'
      config.user_password = require_input 'password (blank for prompt)'
      config.session_user = require_input 'Specify user (leave blank to skip)'
      config.save
    end

    # Asks the user to configure a host.
    def self.configure_host(config)
      return unless proceed? "host #{config.host} not known"
      config.port = require_input 'port number (leave blank for default)'
      config.save
    end

    # Creates a new database configuratin YAML file.
    def self.db_config!(file, global_options)
      return if File.exist?(global_options[:db_config])
      STDERR.puts "Creating new config file #{file}"
      Specify::Configuration::Config.empty file do |config|
        config.add_host global_options[:host], global_options[:port]
      end
    end

    # Asks the user to proceed. Returns +true+ if the user answers answers with
    # 'Yes'.
    def self.proceed?(message)
      STDERR.puts message
      STDERR.print "Configure? (Y/n)"
      return true if /^[Yy](es)?/.match Readline.readline(': ')
    end

    # Prompts the user for input with +message+.
    def self.require_input(message)
      STDERR.print message
      answer = Readline.readline(': ')
      return if answer.empty?
      answer
    end
  end
end
