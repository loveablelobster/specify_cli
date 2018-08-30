# frozen_string_literal: true

module Specify
  module Configuration
    # Configurations wrap a database configuaratin file (_.rc.yaml_ file).
    #
    # Configuration is the superclass of the DBConfig and HostConfig classes.
    class Config
      # A Hash containing the directory-host-mapping parameters for the
      # HostConfig subclass.
      attr_reader :dir_names

      # A Hash containing the database parameters for the DBConfig subclass.
      attr_reader :hosts

      # Returns a new empty Config for +file+ that can serve as a template.
      #
      # +file+: the YAML file containg the configuration
      def self.empty(file, &block)
        if File.exist?(file)
          raise "#{file} exists, won't overwrite"
        end
        config = new file, dir_names: {}, hosts: {}, &block
        config.save
        config
      end

      # Returns a new Config for +file+ (a YAML file containg the
      # configuration).
      #
      # <tt>dir_names</tt>: a Hash with directory names as keys, host names as
      # values.
      #
      # +hosts+: a Hash with host configurations. The hash should have the
      # structure:
      #   {
      #     :hosts => {
      #       'hostname' => {
      #         :port => Integer,
      #         :databases => {
      #           'database name' => {
      #             :db_user => {
      #               :name => 'mysql_user_name',
      #               :password => 'password'
      #             },
      #             :sp_user => 'specify_user_name'
      #           }
      #         }
      #       }
      #     }
      #   }
      # Leave +:password+ out to be prompted.
      def initialize(file = nil, dir_names: nil, hosts: nil)
        @file = Pathname.new(file)
        if dir_names || hosts
          @dir_names = dir_names
          @hosts = hosts
          @params = { dir_names: dir_names, hosts: hosts }
        else
          @params = Psych.load_file(@file)
          @dir_names = @params[:dir_names]
          @hosts = @params[:hosts]
        end
        yield(self) if block_given?
        @saved = nil
      end

      # Adds a configuration for the database with +name+ to the +host+
      # configuration.
      def add_database(name, host:)
        add_host(host) unless hosts[host]
        if hosts.dig host, :databases, name
          raise "Database '#{name}' on '#{host}' already configured"
        end
        db = hosts[host][:databases][name] = db_template
        yield(db) if block_given?
        @saved = false
      end

      # Adds a configuration for the host with +name+.
      def add_host(name, port = nil)
        raise "Host '#{name}' already configured" if hosts[name]
        hosts[name] = { port: port, databases: {} }
        @saved = false
      end

      # Returns a Hash with the contents of the configuration YAML file.
      def params
        { dir_names: @dir_names, hosts: @hosts }
      end

      # Saves the current state to the YAML configuration file.
      def save
        File.open(@file, 'w') do |file|
          file.write(Psych.dump(@params))
        end
        @saved = true
      end

      # Returns +false+ if the instance has been modified since the last save.
      def saved?
        @saved
      end

      # Marks the instance as modified.
      def touch
        @saved = false
      end

      private

      def db_template
        {
          db_user: { name: nil, password: nil },
          sp_user: nil
        }
      end
    end
  end
end
