# frozen_string_literal: true

module Specify
  module Service
    # Superclass for service classes.
    class Service
      attr_reader :session, :agent, :collection, :discipline, :division, :user

      def initialize(host:,
                     database:,
                     collection:,
                     specify_user: nil,
                     config: nil)
        config ||= DATABASES
        @config = Configuration::DBConfig.new(host, database, config)
        @db = Database.new database, @config.connection
        session_user = specify_user || @config.session_user
        @session = @db.start_session session_user, collection
        @collection = @session.collection
        @discipline = @session.discipline
        @division = @session.division
        @agent = @session.session_agent
      end
    end
  end
end
