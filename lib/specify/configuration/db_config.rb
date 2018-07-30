# frozen_string_literal: true

module Specify
  module Configuration
    # A class that wraps a yml .rc file
    class DBConfig < Config
      attr_reader :host, :port, :database

      def initialize(host, database, file = nil)
        super(file)
        @host = host
        @port = hosts.dig(@host, :port) || 3306
        @database = database
      end

      def connection
        { host: host,
          port: port,
          user: params.dig(:db_user, :name),
          password: params.dig(:db_user, :password) }
      end

      def params
        super.dig :hosts, @host, :databases, @database
      end

      def session_user
        params[:sp_user]
      end
    end
  end
end
