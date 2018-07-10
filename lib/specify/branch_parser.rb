# frozen_string_literal: true

module Specify
  # A class that parses target information (_hostname_, _database_,
  # _collection_, _level_) from a string that follows the convention
  # <tt>Database/Collection/level</tt> this can be the name of a git branch of
  # a repository residing in a folder denoting the hostname.
  class BranchParser
    attr_reader :collection, :config, :database, :host, :user

    def initialize(name, config = nil)
      @config = Configuration::HostConfig.new(config)
      file_dir, @database, collection, @level, @user = *name.split('/')
      raise ArgumentError, BRANCH_ERROR + name unless collection && level
      @host = @config.resolve_host file_dir
      @collection = normalize_name collection
    end

    # Creates a new instance of BranchParser from the current HEAD.
    def self.current_branch(config = nil)
      stdout_str, stderr_str, status = Open3.capture3(GIT_CURRENT_BRANCH)
      unless status.exitstatus.zero?
        STDERR.puts "There was an error running #{GIT_CURRENT_BRANCH}"
        STDERR.puts stderr_str
        exit 1
      end
      dir_and_branch = File.basename(Dir.pwd) + '/' + stdout_str.chomp
      new(dir_and_branch, config)
    end

    # Returns the BranchParser object's attributes as a hash.
    def to_h
      { host: host,
        database: database,
        collection: collection,
        level: level }
    end

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
