# frozen_string_literal: true

module SPResource
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
      b_name = `git rev-parse --abbrev-ref HEAD`
      return nil if b_name.start_with?('fatal:')
      new(b_name.chomp)
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
