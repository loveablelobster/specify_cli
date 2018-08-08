# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class DBConfig < Config
      attr_reader :host, :port, :database

      def initialize(host, database, file = nil)
        super(file)
        @host = host
        @database = database
        @port = hosts.dig(@host, :port) || 3306
      end

      def connection
        { host: host,
          port: port,
          user: params.dig(:db_user, :name),
          password: params.dig(:db_user, :password) }
      end

      # -> +true+ or +false+
      # returns true if the database is known (has been configured)
      def known?
        params ? true : false
      end

      def params
        super.dig :hosts, @host, :databases, @database
      end

      def session_user
        params[:sp_user]
      end

      def configure_host
        return unless proceed? "host #{host} not known"
        port = require_input 'port number (leave blank for default)'
        raise 'invalid port' unless port.nil? || port.to_i > 0
        add_host(host, port&.to_i)
        save
      end

      def configure_database
        return unless proceed? "database #{database} not known"
        add_database database, host: host do |db|
          db[:db_user][:name] = require_input 'MySQL user name'
          db[:db_user][:password] = require_input 'password (blank for prompt)'
          db[:sp_user] = require_input 'Specify user (leave blank to skip)'
        end
        save
      end
    end
  end
end
