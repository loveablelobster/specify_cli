# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class Config
      attr_reader :dir_names, :hosts

      # -> Configuration::Config
      # Creates a new instance
      # _file_: the YAML file (path) containg the configuration
      # <em>dir_names</em>: a Hash with directory names as keys, hosts as values
      # _hosts_: a Hash with host configurations
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

      # -> Configuration::Config
      # Returns a new empty instance that can serve as a template.
      # _file_: the YAML file (path) containg the configuration
      def self.empty(file, &block)
        if File.exist?(file)
          raise "#{file} exists, won't overwrite"
        end
        config = new file, dir_names: {}, hosts: {}, &block
        config.save
        config
      end

      # Adds a host configuration hash
      # <tt>{ _hostname_ => { port: _portnumber_, databases: {} } }</tt>
      # _name_: String, the host name
      # _port_: Interger, the port number
      def add_host(name, port = nil)
        raise "Host '#{name}' already configured" if hosts[name]
        hosts[name] = { port: port, databases: {} }
        @saved = false
      end

      # Adds a database configuration hash to the host configuration's
      # +databases+ key:
      # <tt>_databasename_ => { db_user: { name: _nil_, password: _nil_ } }</tt>
      # _name_: String, the database name
      # _host_: String, the name of the MySQL/MariaDB host for the database
      def add_database(name, host:)
        add_host(host) unless hosts[host]
        if hosts.dig host, :databases, name
          raise "Database '#{name}' on '#{host}' already configured"
        end
        db = hosts[host][:databases][name] = db_template
        yield(db) if block_given?
        @saved = false
      end

      # -> Hash
      # Returns a Hash with the contents of the configuration YAML file.
      def params
        { dir_names: @dir_names, hosts: @hosts }
      end

      # -> +true+
      # Saves the current contens fo _params_ to the YAML configuration _file_.
      def save
        File.open(@file, 'w') do |file|
          file.write(Psych.dump(@params))
        end
        @saved = true
      end

      # -> +true+ or +false+
      # Returns +false+ if the instance has been modified since the last save.
      def saved?
        @saved
      end

      # Sets the _saved_ state to +false+
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
