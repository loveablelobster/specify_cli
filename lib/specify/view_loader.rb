# frozen_string_literal: true

module Specify
  # A class that can upload a ViewSetObject
  class ViewLoader
    attr_reader :target
    # _database_: the database
    # _collection_: the collection for the session and the target
    # _level_: Hash (with user)
    def initialize(host:, database:, collection:, level:, config: nil)
      config ||= DATABASES
      @config = Configuration::DBConfig.new(host, database, config)
      @db = Database.new database, @config.connection
      @session = @db.start_session @config.session_user, collection
      @target = nil
      self.target = level
    end

    # Returns a string containing a human-readable representation of Session.
    def inspect
      "#{self} database: #{@db.database}, target: #{@target}"
    end

    # Creates a new instance from a branch name
    def self.from_branch(name = nil, config: nil)
      params = name ? BranchParser.new(name) : BranchParser.current_branch
      new params.to_h.merge(config: config)
    end

    def target=(level)
      @target = case level
                when :collection
                  @session.collection
                when :discipline
                  @session.collection.discipline
                else
                  user_target(level) || user_type_target(level)
                end
    end

    def import(file)
      view_set = @target.view_set(@session.collection) # || @target.create_view_set
      view_set.import(views_file(file))
    end

    private

    def views_file(path_name)
      path = Pathname.new path_name
      return File.open path if path.file? && path.fnmatch?('*.views.xml')
      raise ArgumentError, FileError::VIEWS_FILE
    end

    def user_target(hash)
      return unless hash.key? :user
      Model::User.first(Name: hash[:user])
    end

    def user_type_target(hash)
      return unless hash.key? :user_type
      UserType.new(hash[:user_type])
    end
  end
end
