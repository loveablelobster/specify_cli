# frozen_string_literal: true

module SPResource
  # A module that provides logic to work with a Specify database.
  module Specify
    # A class that represents a Specify database.
    class Database
      attr_accessor :connection
      attr_reader :database, :host, :port, :sessions

      # Creates a new instance.
      # _database_: the name of the MySQL database to connect to
      # _host_: the host name or IP
      # _user_: the MySQL user
      # _password_: the password
      def initialize(database,
                     host: 'localhost',
                     port: 3306,
                     user: 'root',
                     password: nil)
        @database = database
        @host = host
        @port = port
        @user = user
        @password = password || prompt
        @connection = nil
        @sessions = []
        ObjectSpace.define_finalizer(self, method(:close))
        yield(self) if block_given?
      end

      # Returns a string containing a human-readable representation of Database.
      def inspect
        "#{self} database: #{@database}, host: #{@host}, port: #{@port}"\
        ", user: #{@user}, connected: #{connection ? true : false}"
      end

      # Deletes a closed session from the sessions pool
      def update(session)
        return if session.open?
        sessions.delete session
      end

      # Creates a new instance from a config file.
      # Default config file is '/usr/local/etc/sp_view_loader/db.yml'
      # _database_: the name of the database
      # _config_file_: the path to the file
      def self.load_config(database, config_file = nil)
        config = Psych.load_file(config_file || CONFIG)[database]
        new(database,
            host: config['host'],
            port: config['port'],
            user: config['db_user']['name'],
            password: config['db_user']['password'])
      end

      # Adds a new Session to the sessions pool.
      def <<(session)
        return unless session.open?
        sessions << session
      end

      def start_session(user, collection)
        connect
        session = Session.new self, user, collection
        sessions << session.open
        session
      end

      #
      def close
        return if sessions.empty?
        puts 'cleaning up hanging sessions:'
        sessions.each do |session|
          puts session
          session.close
        end
      end

      # Returns the Sequel::Database object for the database. Establishes a
      # connection and creates the object if it does not already exist.
      def connect
        return connection if connection
        connection = Sequel.connect adapter: :mysql2,
                                     user: @user,
                                     password: @password,
                                     host: @host,
                                     port: @port,
                                     database: @database
        require_relative 'models'
        connection
      end

      private

      # Prompts the user for the _password_
      def prompt
        print 'password: '
        STDIN.noecho(&:gets).chomp
      end
    end
  end
end
