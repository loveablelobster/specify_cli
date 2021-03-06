# frozen_string_literal: true

module Specify
  module CLI
    # Parses the _level_ for the Specify::Service::ViewLoader to upload
    # _.vioews.xml_ files to from the command +options+.
    def self.level(options)
      if options[:d]
        :discipline
      elsif options[:c]
        :collection
      elsif options[:t]
        { user_type: options[:t] }
      elsif options[:u]
        { user: options[:u] }
      else
        raise 'level required (use -d, -c, -t, or -u option)'
      end
    end
  end
end
