# frozen_string_literal: true

module Specify
  # Databases represent _Specify_ database.
  class Database
    # The Sequel::Database instance for the current connection.
    attr_accessor :connection

    # The name of the _Specify_ database.
    attr_reader :database

    # The name of the MySQL/MariaDB host for the _Specify_ database.
    attr_reader :host

    # The port for the MySQL/MariaDB server for the _Specify_ database.
    attr_reader :port

    # An Array of Specify::Session instances currently registered (and open).
    attr_reader :sessions

    # The MySQL/MariaDB user for the database. This is typically the _Specify_
    # <em>master user</em>.
    attr_reader :user

    # Creates a new Database from +config_file+ file (a _YAML_ file).
    #
    # +config_file+ should have the structure:
    #     ---
    #     :hosts:
    #       <hostname>:
    #         :port: <port_number>
    #         :databases:
    #           <database_name>:
    #             :db_user:
    #               :name: <mysql_username>
    #               :password: <password>
    #             :sp_user: <specify_username>
    #
    # Items prefices with +:+ will be deserialized as symbols. Leave
    # +:password:+ blank to be prompted.
    #
    # +host+: the name of the MySQL/MariaDB host for the database.
    # +database+: the name of the MySQL/MariaDB database.
    def self.load_config(host, database, config_file = nil)
      config = Configuration::DBConfig.new(host, database, config_file)
      new(database, config.connection)
    end

    # Returns a new Database for the +database+ (the name of the database) on
    # +host+.
    #
    # +port+: the port for the MySQL/MariaDB server for the database.
    #
    # +user+: the MySQL/MariaDB user (typically the _Specify_
    # <em>master user</em>).
    #
    # +password+: the password for the MySQL/MariaDB user.
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

    # Adds a new Session to the sessions pool.
    def <<(session)
      session.open
      session.add_observer self
      sessions << session
    end

    # Closes all sessions.
    def close
      return if sessions.empty?
      sessions.each do |session|
        session.close
        session.delete_observer self
      end
      # TODO: should close database connection
    end

    # Establishes a connection and creates the object if it does not already
    # exist. Loads all Specify::Model classes.
    #
    # Returns the Sequel::Database object for the database.
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

    # Creates a string representation of +self+.
    def inspect
      "#{self} database: #{@database}, host: #{@host}, port: #{@port}"\
      ", user: #{@user}, connected: #{connection ? true : false}"
    end

    # Createas a new Session for +user+ (String, an existing
    # Specify::Model::User#name) in +collection+ (String, an existing
    # Specify::Model::Collection#name) and adds it to the #sessions pool.
    #
    # Returns the new Session.
    def start_session(user, collection)
      connect
      session = Session.new user, collection
      self << session
      session
    end

    # Deletes a +session+ (a Session) from the sessions pool when +session+
    # has been closed.
    def update(session)
      sessions.delete session
    end

    private

    def prompt
      print 'password: '
      password = STDIN.noecho(&:gets).chomp
      puts
      password
    end
  end
end
