# frozen_string_literal: true

module SpResource
  #
  class BranchParser
    def initialize(name)
      @database, collection, level, user = *name.split('/')
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

    def self.current_branch
      stdout_str, stderr_str, status = Open3.capture3(GIT_CURRENT_BRANCH)
      unless status.exitstatus == 0 #if b_name.start_with?('fatal:')
        STDERR.puts "There was an error running #{GIT_CURRENT_BRANCH}"
        STDERR.puts stderr_str
        exit 1
      end
      new(stdout_str.chomp)
    end

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
