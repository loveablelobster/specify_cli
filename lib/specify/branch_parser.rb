# frozen_string_literal: true

module Specify
  # BranchParsers parse the information required to set a
  # Specify::Service::ViewLoade#target for upload of _.views.xml_ files from a
  # string that follows the convention <tt>Database/CollectionName/level</tt>.
  #
  # This can be the name of a git branch of a repository residing in a folder
  # denoting the hostname.
  class BranchParser
    # The name of the collection. Must be an existing
    # Specify::Model::Collection#name.
    attr_reader :collection

    # A Specify::Configuration::HostConfig.
    attr_reader :config

    # The name of a _Specify_ database.
    attr_reader :database

    # The name of a MySQL/MariaDB host.
    attr_reader :host

    # The name of a _Specify_ user (an existing Specify::Model::User#name).
    attr_reader :user

    # Creates a new instance of BranchParser for the current Git _HEAD_.
    #
    # +config+: a database configuration YAML file.
    def self.current_branch(config)
      stdout_str, stderr_str, status = Open3.capture3(GIT_CURRENT_BRANCH)
      unless status.exitstatus.zero?
        STDERR.puts "There was an error running #{GIT_CURRENT_BRANCH}"
        STDERR.puts stderr_str
        exit 1
      end
      branch = stdout_str.chomp
      new(Dir.pwd, branch, config)
    end

    # Returns a new BranchParser with +view_file_path+ and +name+.
    #
    # +view_file_path+: the directory path of the _.vews.xml_ file (that path
    # must be mapped to a host name in the +config+).
    #
    # +name+: a String with a branch name conforming to the convention
    # <tt>Database/CollectionName/level</tt>.
    #
    # +config+: a database configuration YAML file.
    def initialize(view_file_path, name, config = nil)
      @config = Configuration::HostConfig.new(config)
      @database, collection, @level, @user = *name.split('/')
      raise ArgumentError, BRANCH_ERROR + name unless collection && level
      @host = @config.resolve_host view_file_path
      @collection = normalize_name collection
    end

    # Returns the attributes of +self+ as a hash.
    def to_h
      { host: host,
        database: database,
        collection: collection,
        level: level }
    end

    # Returns the level to a Specify::Service::ViewLoader will upload.
    def level
      case @level
      when 'collection', 'discipline'
        @level.to_sym
      when 'user'
        { user: @user }
      else
        { user_type: @level.downcase.to_sym }
      end
    end

    private

    def normalize_name(name)
      name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1 \2')
          .gsub(/([a-z\d])([A-Z])/, '\1 \2')
    end
  end
end
