# frozen_string_literal: true

module Specify
  # A class that represents a Specify database.
  class Database
    attr_accessor :connection
    attr_reader :database, :host, :port, :user, :sessions

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

    # Creates a new instance from a config file.
    # Default config file is '/usr/local/etc/sp_view_loader/db.yml'
    # _database_: the name of the database
    # _config_file_: the path to the file
    def self.load_config(host, database, config_file = nil)
      config = Configuration::DBConfig.new(host, database, config)
      new(database, config.connection)
    end

    # Adds a new Session to the sessions pool.
    def <<(session)
      session.open
      session.add_observer self
      sessions << session
    end

    # Closes all sessions.
    # FIXME: should probably also close database connection
    def close
      return if sessions.empty?
      sessions.each do |session|
        session.close
        session.delete_observer self
      end
      # connection.disconnect
    end

    # Returns the Sequel::Database object for the database. Establishes a
    # connection and creates the object if it does not already exist.
    def connect
      return connection if connection
      @connection = Sequel.connect adapter: :mysql2,
                                   user: @user,
                                   password: @password,
                                   host: @host,
                                   port: @port,
                                   database: @database
      require_relative 'models'
      connection
    end

    # Returns a string containing a human-readable representation of Database.
    def inspect
      "#{self} database: #{@database}, host: #{@host}, port: #{@port}"\
      ", user: #{@user}, connected: #{connection ? true : false}"
    end

    # Deletes a closed session from the sessions pool
    def update(session)
      sessions.delete session
    end

    def start_session(user, collection)
      connect
      session = Session.new user, collection
      @sessions << session
      session
    end

    private

    # Prompts the user for the _password_
    def prompt
      print 'password: '
      STDIN.noecho(&:gets).chomp
    end
  end
end
