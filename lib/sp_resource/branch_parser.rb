# frozen_string_literal: true

module SpResource
  # A class that parses target information (_database_, _collection_, _level_)
  # from a string that follows the convention <tt>Database/Collection/level</tt>
  # this can be the name of a git branch.
  class BranchParser
    attr_reader :database, :collection, :level
    def initialize(name)
      @database, collection, level, user = *name.split('/')
      raise ArgumentError, BRANCH_ERROR + name unless collection && level
      @collection = normalize_name collection
      @level = case level
               when 'collection', 'discipline'
                 level.to_sym
               when 'user'
                 { user: user }
               else
                 { user_type: level.downcase.to_sym }
               end
    end

    # Creates a new instance of BranchParser from the current HEAD.
    def self.current_branch
      stdout_str, stderr_str, status = Open3.capture3(GIT_CURRENT_BRANCH)
      unless status.exitstatus.zero?
        STDERR.puts "There was an error running #{GIT_CURRENT_BRANCH}"
        STDERR.puts stderr_str
        exit 1
      end
      new(stdout_str.chomp)
    end

    # Returns the BranchParser object's attributes as a hash.
    def to_h
      { database: @database, collection: @collection, level: @level }
    end

    private

    def normalize_name(name)
      name.gsub(/([A-Z]+)([A-Z][a-z])/, '\1 \2')
          .gsub(/([a-z\d])([A-Z])/, '\1 \2')
    end
  end
end
