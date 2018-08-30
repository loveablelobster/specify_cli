# frozen_string_literal: true

module Specify
  module Model
    # Users represent _Specify_ users.
    class User < Sequel::Model(:specifyuser)
      include Updateable

      one_to_many :agents,
                  key: :SpecifyUserID
      one_to_many :app_resource_dirs,
                  key: :SpecifyUserID

      # Returns +true+ if +collection+ (a Specify::Model::Collection) is the
      # same #login_collection.
      def collection_valid?(collection)
        login_collection == collection
      end

      # Creates a string representation of +self+.
      def inspect
        "#{self} user name: #{self.Name}, logged in: #{self.IsLoggedIn}"
      end

      # Logs the user in to +collection+ (a Specify::Model::Collection).
      #
      # Returns a Hash with the Specify::Model::Collection as key, the timestamp
      # for the login as the value.
      def log_in(collection)
        logged_in?(collection) || new_login(collection)
      end

      # Logs the user out.
      #
      # Returns the timestamp for the logout.
      def log_out
        return true unless self[:IsLoggedIn]
        self[:LoginOutTime] = Time.now
        self[:IsLoggedIn] = false
        self[:LoginCollectionName] = nil
        self[:LoginDisciplineName] = nil
        save
        self[:LoginOutTime]
      end

      # Returns a Hash with the Specify::Model::Collection as key, the timestamp
      # for the login as the value if +self+ is logged in to +collection+ (a
      # Specify::Model::Collection), +nil+ otherwise.
      def logged_in?(collection)
        return nil unless self[:IsLoggedIn]
        raise LoginError::INCONSISTENT_LOGIN unless collection_valid? collection
        { collection => self[:LoginOutTime] }
      end

      # Returns the Specify::Model::Agent for +self+ in the
      # Specify::Model::Division division to which the login_discipline belongs.
      def logged_in_agent
        agents_dataset.first(division: login_discipline.division)
      end

      # Returns the Specify::Model::Collection that +self+ is logged in to.
      def login_collection
        login_discipline.collections_dataset
                        .first CollectionName: self[:LoginCollectionName]
      end

      # Returns the Specify::Model::Discipline that +self+ is logged in to.
      def login_discipline
        Discipline.first Name: self[:LoginDisciplineName]
      end

      # Returns a String with the _Specify_ username for +self+.
      def name
        self[:Name]
      end

      # Registers a new login in +collection+ (a Specify::Model::Collection).
      def new_login(collection)
        login_time = Time.now
        self[:LoginOutTime] = login_time
        self[:IsLoggedIn] = true
        self[:LoginCollectionName] = collection[:CollectionName]
        self[:LoginDisciplineName] = collection.discipline[:Name]
        save
        { collection => self[:LoginOutTime] }
      end

      # Returns the Specify::Model::AppResourceDir for +self+ in +collection+
      # (a Specify::Model::Collection).
      def view_set_dir(collection)
        app_resource_dirs_dataset.first(collection: collection,
                                        discipline: collection.discipline,
                                        UserType: self[:UserType],
                                        IsPersonal: true)
      end

      # Returns the Specify::Model::ViewSetObject for +self+ in +collection+ (a
      # Specify::Model::Collection)
      def view_set(collection)
        view_set_dir(collection)&.view_set_object
      end
    end
  end
end
