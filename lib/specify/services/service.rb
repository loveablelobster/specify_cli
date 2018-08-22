# frozen_string_literal: true

module Specify
  module Service
    # Superclass for service classes.
    class Service
      # The Specify::Session#agent for #session.
      attr_reader :agent

      # The Specify::Model::Collection for #session.
      attr_reader :collection

      # The Specify::Model::Discipline for #session.
      attr_reader :discipline

      # The Specify::Model::Division for #session.
      attr_reader :division

      # The Specify::Session for +self+ (the session that the Service uses
      # during work with a Specify::Database).
      attr_reader :session

      # Returns a new Service.
      #
      # +host+: the hostname for the MySQL/MariaDB server.
      #
      # +database+: a String with a Specify::Database#database.
      #
      # +collection+: a String with an existing Specify::Model::Collection#name.
      #
      # +config+: a YAML file containing the database configuration.
      #
      # +specify_user+: a String with an existing Specify::Model::User#name.
      def initialize(host:, database:, collection:, config:, specify_user: nil)
        @config = Configuration::DBConfig.new(host, database, config)
        @db = Database.new database, @config.connection
        session_user = specify_user || @config.session_user
        @session = @db.start_session session_user, collection
        @collection = @session.collection
        @discipline = @session.discipline
        @division = @session.division
        @agent = @session.session_agent
      end

      # Returns the Sequel::Database instance for the current connection.
      def database
        @db.connection
      end
    end
  end
end
