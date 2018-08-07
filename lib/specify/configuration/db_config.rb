# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class DBConfig < Config
      attr_reader :host, :port, :database

      def initialize(host, database, file = nil)
        super(file)
        @host = host
        configure_host unless hosts[@host]
        @database = database
        configure_database unless known?
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

      private

      def configure_host
        exit 1 unless proceed?(:host)
        port = require_input 'port number (leave blank for default)'
        raise 'invalid port' unless port.nil? || port.to_i > 0
        add_host(host, port&.to_i)
        save # should rather mark an ivar as changed
      end

      def configure_database
        exit 1 unless proceed?(:database)
        add_database database, host: host do |db|
          db[:db_user][:name] = require_input 'MySQL user name'
          db[:db_user][:password] = require_input 'password (blank for prompt)'
          db[:sp_user] = require_input 'Specify user (leave blank to skip)'
        end
        save
      end

      def proceed?(item)
        STDERR.puts "#{item.to_s.capitalize} #{public_send(item)} is not known."
        STDERR.puts "Configure? (Y/n)"
        return true if /^[Yy](es)?/.match Readline.readline('> ')
      end
    end
  end
end
