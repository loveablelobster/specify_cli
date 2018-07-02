# frozen_string_literal: true

module Specify
  module CLI
    def self.ask(config, keys)
      setting = config.dig(*keys)
      confidential = keys.last == 'password'
      current = confidential ? '********' : setting
      message = setting ? " (current: #{current}, leave blank to keep)" : ''
      print "#{keys[1..-1].join(' ')}#{message}"
      user_input = Readline.readline ': ', !confidential
      setting = user_input unless user_input.empty?
      raise ArgumentError, "#{keys[1..-1].join(' ')} required" unless setting
      setting
    end

    def self.config?
      File.exist?(CONFIG)
    end

    def self.config_template(database = 'database_name', config = {})
      db = { 'host' => nil, 'port' => nil,
             'db_user' => { 'name' => nil, 'password' => nil },
             'sp_user' => nil }
      config[database] = db
    end

    def self.configure(config, database)
      if config[database]
        overwrite? database
      else
        config_template database, config
      end
      puts configure! config, database
    end

    def self.configure!(config, database)
      config[database] ||= {}
      questions = %w[host port db_user&name db_user&password sp_user]
      questions.each do |question|
        keys = question.split('&').unshift(database)
        keys[0...-1].reduce(config) do |hash, key|
          hash.public_send(:[], key)
        end.public_send(:[]=, keys.last, ask(config, keys))
      end
      config
    end

    def self.load_config
      return unless config?
      Psych.load_file(CONFIG)
    end

    def self.save_config(yaml)
      File.open(CONFIG, 'w') do |file|
        file.write(Psych.dump(yaml))
      end
    end

    def self.overwrite?(database)
      puts "configuration for #{database} exists"
      print 'overwrite? (Yes/No)'
      choice = Readline.readline(': ', true)
      /^((?<no>no?)|(?<yes>y(es)?))$/i.match choice do |m|
        exit 0 if m[:no]
        return true if m[:yes]
      end
      puts "invalid choice: #{choice}"
      overwrite? database
    end
  end
end
