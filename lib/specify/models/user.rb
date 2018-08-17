# frozen_string_literal: true

module Specify
  module Model
    # A class that represents a Specify user.
    class User < Sequel::Model(:specifyuser)
      one_to_many :agents, key: :SpecifyUserID
      one_to_many :app_resource_dirs, key: :SpecifyUserID

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      # -> String
      # Returns a string containing a human-readable representation of User.
      def inspect
        "#{self} user name: #{self.Name}, logged in: #{self.IsLoggedIn}"
      end

      # -> +true+ or +false+
      # Returns +true+ if _collection_ is consistent with the combination of
      # Model::Collection and Model::Disciplin as registered in the databse.
      # _collection_: a Model::Collection
      def collection_valid?(collection)
        c_match = self.LoginCollectionName == collection[:CollectionName]
        d_match = self.LoginDisciplineName == collection.discipline[:Name]
        d_match && c_match
      end

      # -> Hash
      # Logs the user in to _collection_
      # _collection_: a Model::Collection
      def log_in(collection)
        logged_in?(collection) || new_login(collection)
      end

      # -> Time
      # Logs the user out of the system.
      def log_out
        return true unless self.IsLoggedIn
        self.LoginOutTime = Time.now
        self.IsLoggedIn = false
        self.LoginCollectionName = nil
        self.LoginDisciplineName = nil
        save
        self.LoginOutTime
      end

      # -> Hash or +nil+
      # Returns the collection and login time if the user is logged in to
      # _collection_.
      # _collection_: a Model::Collection
      def logged_in?(collection)
        return nil unless self.IsLoggedIn
        raise LoginError::INCONSISTENT_LOGIN unless collection_valid? collection
        { collection => self.LoginOutTime }
      end

      # -> Specify::Model::Agent
      # Returns the Model::Agent for the division of the collection the user is
      # logged in to.
      def logged_in_agent
        division = Discipline.first(Name: self.LoginDisciplineName).division
        agents_dataset.first(division: division)
      end

      # Returns a String with the Specify username.
      def name
        self.Name
      end

      # -> Hash
      # Registers a new login in _collection_ with the database.
      # _collection_: a Model::Collection
      def new_login(collection)
        login_time = Time.now
        self.LoginOutTime = login_time
        self.IsLoggedIn = true
        self.LoginCollectionName = collection[:CollectionName]
        self.LoginDisciplineName = collection.discipline[:Name]
        save
        { collection => self.LoginOutTime }
      end

      # -> Specify::Model::AppResourceDir
      # Returns the user's AppResourceDir instances for _collection_.
      # _collection_: a Model::Collection
      def view_set_dir(collection)
        app_resource_dirs_dataset.first(collection: collection,
                                        discipline: collection.discipline,
                                        UserType: self[:UserType],
                                        IsPersonal: true)
      end

      # -> Specify::Model::ViewSetObject
      # Returns the user's ViewSetObject for _collection_.
      # _collection_: a Model::Collection
      def view_set(collection)
        view_set_dir(collection)&.view_set_object
      end
    end
  end
end
