# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class DBConfig < Config
      attr_reader :host, :database, :params

      def initialize(host, database, file = nil)
        super(file)
        @host = host
        @database = database
        @params = params.dig('hosts', host, 'databases', database)
      end

      def connection
        { host: host,
          port: params.fetch('port'),
          user: params.dig('db_user', 'name'),
          password: params.dig('db_user', 'password') }
      end

      def session_user
        params['sp_user']
      end
    end
  end
end
