# frozen_string_literal: true

def config?
  File.exist?(CONFIG)
end

def load_config
  return unless config?
  Psych.load_file(CONFIG)
end

def save_config(yaml)
  # FIXME: create directory /usr/local/etc/sp_resource/ if it does not exist
  File.open(CONFIG, 'w') do |file|
    file.write(Psych.dump(yaml))
  end
end
