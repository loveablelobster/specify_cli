# frozen_string_literal: true

module Specify
  module Service
    # ViewLoaders will upload _.views.xml_ files to the Specify database.
    class ViewLoader < Service
      # The target to which the ViewLoader uploads _.views.xml_ files; an
      # instance of Specify::Model::Discipline, Specify::Model::Collection,
      # Specify::UserType, or Specify::Model::User
      attr_reader :target

      # Creates a new instance from a branch +name+, if +name+ conforms to the
      # naming convention <em>database_name/collection_name/level</em>, where
      # _level_ is _discipline_, _collection_, _manager_, _fullaccess_,
      # _limitedaccess_, or _guest_), or _user/username_.
      #
      # +path+ is the filepath for the view file to be uploaded.
      #
      # +config+ is the yaml file containing the database configuration.
      def self.from_branch(config:, path: nil, name: nil)
        parser = if name
                   BranchParser.new(path, name, config)
                 else
                   BranchParser.current_branch config
                 end
        new parser.to_h.merge(config: config)
      end

      # Returns the Specify::Model::User instance for +hash+ if +hash+ has the
      # key +:user+ and the value for that key is an existing
      # Specify::Model::User#name.
      def self.user_target(hash)
        return unless hash.key? :user
        Model::User.first(Name: hash[:user])
      end

      # Returns the Specify::UserType for +hash+ if hash has the key
      # +user_type+, and the value for that key is a valid
      # Specify::UserType#name.
      def self.user_type_target(hash)
        return unless hash.key? :user_type
        UserType.new(hash[:user_type])
      end

      # Returns a new ViewLoader.
      #
      # +level+ is the level to which the _.views.xml_ file will be uploaded.
      # valid values are _:discipline_, _:collection_,
      # <tt>{ :user_type => String }</tt> (String Symbol must be a valid
      # Specify::UserType#name) or <tt>{ :user => String }</tt> (where String
      # must be an existing Specify::Model::User#user name).
      def initialize(host:,
                     database:,
                     collection:,
                     specify_user: nil,
                     level: nil,
                     config:)
        super(host: host,
              database: database,
              collection: collection,
              specify_user: specify_user,
              config: config)
        @target = nil
        self.target = level
      end

      # Creates a string representation of +self+.
      def inspect
        "#{self} database: #{@db.database}, target: #{@target}"
      end

      # Loads the _views.xml_ +file+ and stores it as a SQL blob in the
      # Specify::Model::ViewSetObject for the #target.
      def import(file)
        view_set = @target.view_set(collection) ||
                   create_view_set(file)
        view_set.import(views_file(file))
      end

      # Returns +true+ if the view is personal, +false+ otherwise.
      def personal?
        @target.is_a?(Model::User) ? true : false
      end

      # Sets the target for the instance. +level+ must be +:discipline+,
      # +:collection+, or a Hash with the key :user_type and a valid
      # Specify::UserType#name as value or the key +:user+ and an existing
      # Specify::Model::User#name.
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

      # Returns the Specify::Model::Collection that _views.xml_ files will be
      # uploaded to (all supported upload levels except +:disciplin+ are
      # scoped to a collection. Will be #collection or +nil+.
      def view_collection
        collection unless @target.is_a? Model::Discipline
      end

      # Returns the Specify::Model::Discipline that _views.xml_ files will be
      # uploaded to.
      def view_discipline
        discipline
      end

      # Returns +2+ if the view is for a collection, +0+ otherwise.
      def view_level
        @target.is_a?(Model::Collection) ? 2 : 0
      end

      # Returns the Specify::Model::Discipline#name, which is the
      # Specify::Model::AppResourceDir#discipline_type.
      def view_type
        view_discipline.name
      end

      # Returns the Specify::Model::User that _views.xml_ files will be
      # uploaded to. Same as #session Specify::Session#user unless the view is
      # for a different user.
      def view_user
        @target.is_a?(Model::User) ? @target : @session.user
      end

      # Returns a String with a valid Specify::UserType#name for #target.
      def view_user_type
        case @target
        when UserType
          @target.name.to_s
        when Model::User
          @target.UserType.downcase
        end
      end

      private

      def create_view_dir
        vals = { created_by: agent,
                 DisciplineType: view_type,
                 UserType: view_user_type,
                 IsPersonal: personal?,
                 collection: view_collection,
                 discipline: view_discipline,
                 user: view_user }
        @target.view_set_dir = @target.add_app_resource_dir(vals)
      end

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

      def views_file(file)
        raise ArgumentError, FileError::NO_FILE unless File.exist?(file)
        path = Pathname.new file
        return File.open path if path.file? && path.fnmatch?('*.views.xml')
        raise ArgumentError, FileError::VIEWS_FILE
      end
    end
  end
end
