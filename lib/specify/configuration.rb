# frozen_string_literal: true

module Specify
  # A class that wraps a yml .rc file
  class Configuration
    attr_reader :host, :database

    def initialize(file: nil, host:, database:)
      @yaml = Psych.load_file(file || CONFIG)
      @host = host
      @database = database
    end

    def connection(host, database)
      params = database_params host, database
      [database, { host: params['host'],
                   port: params['port'],
                   user: params.dig('db_user', 'name'),
                   password: params.dig('db_user', 'password') }]
    end

    def params
      @yaml.dig('hosts', host, 'databases', database)
    end
  end
end
