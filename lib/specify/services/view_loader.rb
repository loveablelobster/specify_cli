# frozen_string_literal: true

module Specify
  module Service
    # A class that uploads view files.
    class ViewLoader < Service
      attr_reader :target
      # Creates a new instance.
      # _host_: the host for the database to which views are uploaded.
      # _database_: the database to which views are uploaded.
      # _collection_: the collection for the session and the target.
      # _level_: the level at which the view will be uploaded (+:discipline+,
      #          +:collection+, <tt>{ user_type: String }</tt>, or
      #          <tt>{ user: String }.
      # _config_: a yaml file containing the database configuration.
      def initialize(host:,
                     database:,
                     collection:,
                     specify_user: nil,
                     level: nil,
                     config: nil)
        super(host: host,
              database: database,
              collection: collection,
              specify_user: specify_user,
              config: config)
        @target = nil
        self.target = level
      end

      # Returns a string containing a human-readable representation of Session.
      def inspect
        "#{self} database: #{@db.database}, target: #{@target}"
      end

      # -> ViewLoader
      # Creates a new instance from a branch _name_.
      # _config_: a yaml file containing the database configuration.
      def self.from_branch(config:, path: nil, name: nil)
        parser = if name
                   BranchParser.new(path, name, config)
                 else
                   BranchParser.current_branch config
                 end
        new parser.to_h.merge(config: config)
      end

      # -> Model::User
      # Returns the Model::User instance for _hash_.
      # _hash_: <tt>{ user: String }</tt> where _String_ is the user name.
      def self.user_target(hash)
        return unless hash.key? :user
        Model::User.first(Name: hash[:user])
      end

      # -> UserType
      # Returns the UserType for _hash_.
      # _hash_: <tt>{ user_type: String }</tt> where Symbol is :fullaccess,
      #         :guest, :limitedaccess, :manager.
      def self.user_type_target(hash)
        return unless hash.key? :user_type
        UserType.new(hash[:user_type])
      end

      # -> Object
      # Sets the target for the instance.
      # _level_: symbol (+:collection+ or +:discipline+) or Hash
      #          { :user_type => String } for UserType where _String_ is the
      #          UserType _name_.
      #          { :user => String } for User, where _String_ is the user name.
      def target=(level)
        return unless level
        @target = case level
                  when :collection
                    collection
                  when :discipline
                    discipline
                  else
                    ViewLoader.user_target(level) ||
                    ViewLoader.user_type_target(level)
                  end
      end

      # -> Object
      # Persists the contents of _file_ in the database.
      def import(file)
        view_set = @target.view_set(collection) ||
                   create_view_set(file)
        view_set.import(views_file(file))
      end

      # -> Model::Collection or nil
      # Returns the Model::Collection for the _collection_ association of
      # Model::AppResourceDir.
      def view_collection
        collection unless @target.is_a? Model::Discipline
      end

      # -> Model::Discipline
      # Returns the Model::Discipline for the _discipline_ association of
      # Model::AppResourceDir.
      def view_discipline
        discipline
      end

      # -> +true+ or +false+
      # Returns the value for the _IsPersonal_ attribute of
      # Model::AppResourceDir.
      # +true+ if the view is personal, +false+ otherwise.
      def view_is_personal
        @target.is_a?(Model::User) ? true : false
      end

      # -> Integer
      # Returns the value for the _level_ attribute of Model::ViewSetObject.
      # +2+ if the view is for a colletion, +0+ otherwise.
      def view_level
        @target.is_a?(Model::Collection) ? 2 : 0
      end

      # -> String
      # Returns the value for the _DisciplineType_ attribute of
      # Model::AppResourceDir.
      def view_type
        view_discipline.Name
      end

      # -> Model::User
      # Returns the Model::User for the _user_ association of
      # Model::AppResourceDir; the user who uploaded the view unless the view is
      # a personal view for another user.
      def view_user
        @target.is_a?(Model::User) ? @target : @session.user
      end

      # -> String
      # Returns the value for the _UserType_ attribute of Model::AppResourceDir.
      def view_user_type
        case @target
        when UserType
          @target.name.to_s
        when Model::User
          @target.UserType.downcase
        end
      end

      private

      # -> Model::AppResourceDir
      # Creates a new Model::AppResourceDir instance for _target_ and sets
      # _target_'s _view_set_dir_.
      def create_view_dir
        vals = { created_by: agent,
                 DisciplineType: view_type,
                 UserType: view_user_type,
                 IsPersonal: view_is_personal,
                 collection: view_collection,
                 discipline: view_discipline,
                 user: view_user }
        @target.view_set_dir = @target.add_app_resource_dir(vals)
      end

      # -> Model::ViewSetObject
      # Creates a new Model::ViewSetObject and associated Model::AppResourceData
      # instance.
      def create_view_set(file)
        vals = { Level: view_level,
                 FileName: file,
                 Name: file.basename('.xml'),
                 app_resource_dir: create_view_dir,
                 created_by: agent }
        view_set = Model::ViewSetObject.create vals
        Model::AppResourceData.create viewsetobj: view_set,
                                      created_by: agent
        @target.save
        view_set.save
      end

      # -> File
      # Loads _file_.
      def views_file(file)
        raise ArgumentError, FileError::NO_FILE unless File.exist?(file)
        path = Pathname.new file
        return File.open path if path.file? && path.fnmatch?('*.views.xml')
        raise ArgumentError, FileError::VIEWS_FILE
      end
    end
  end
end
