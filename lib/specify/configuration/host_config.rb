# frozen_string_literal: true

module Specify
  module Configuration
    # HostConfigs are configurations that map file directories to host names.
    class HostConfig < Config
      # Retutrns a new HostConfig for +file+ (a YAML file).
      def initialize(file = nil)
        super(file)
        @saved = true
      end

      # Returns +true+ if +directory+ is mapped to a host name.
      def directory?(directory)
        params.key? directory
      end

      # Maps +directory+ to +host+.
      def map_directory(directory, host)
        raise "Directory '#{directory}' already mapped" if params[directory]
        params[directory] = host
        touch
      end

      # Returns a Hash with the parameters for the current directory mappings
      # from the configuration YAML file.
      def params
        super.fetch :dir_names
      end

      # Returns the host name that is mapped to +directory+
      def resolve_host(directory)
        params.fetch directory
      end
    end
  end
end
