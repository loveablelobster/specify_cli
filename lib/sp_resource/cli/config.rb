# frozen_string_literal: true

# first arg of *items must be db
def ask(config, keys)
  setting = config.dig(*keys)
  history = keys.last != 'password'
  message = setting ? " (current: #{setting}, leave blank to keep)" : ''
  print "#{keys[1..-1].join(' ')}#{message}"
  user_input = Readline.readline ': ', history
  setting = user_input unless user_input.empty?
  raise ArgumentError, "#{items.last} required" unless setting
  setting
end

def config?
  File.exist?(CONFIG)
end

def configure(config, database)
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

def load_config
  return unless config?
  Psych.load_file(CONFIG)
end

def save_config(yaml)
  FileUtils.mkdir_p CONFIG_DIR unless File.directory? CONFIG_DIR
  File.open(CONFIG, 'w') do |file|
    file.write(Psych.dump(yaml))
  end
end
