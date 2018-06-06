# frozen_string_literal: true

# first arg of *items must be db
def ask(config, keys)
  setting = config.dig(*keys)
  history = keys.last != 'password'
  message = setting ? " (current: #{setting}, leave blank to keep)" : ''
  print "#{keys[1..-1].join(' ')}#{message}"
  user_input = Readline.readline ': ', history
  setting = user_input unless user_input.empty?
  raise ArgumentError, "#{keys[1..-1].join(' ')} required" unless setting
  setting
end

def config?
  File.exist?(CONFIG)
end

def configure(config, database)
  if config[database]
    overwrite? database
  else
    config[database] = { 'host' => nil, 'port' => nil,
                         'db_user' => {}, 'sp_user' => nil }
  end
  puts configure! config, database
end

def configure!(config, database)
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

def overwrite?(database)
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
