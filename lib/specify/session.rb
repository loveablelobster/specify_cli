# frozen_string_literal: true

require 'observer'

module Specify
  #
  class Session
    include Observable

    attr_reader :collection, :user, :active

    # Creates an instance.
    def initialize(user, collection)
      @user = Model::User.first(Name: user)
      @collection = Model::Collection.first(CollectionName: collection)
      @active = false
    end

    # -> String
    # Returns a string containing a human-readable representation of Session.
    def inspect
      "#{self} specify user: #{@user}"\
      ", collection: #{@collection}, open: #{@active}"
    end

    # -> Session
    # Closes the Session; logs the instance's _user_ out.
    def close
      @user.log_out
      @active = false
      changed
      notify_observers(self)
      self
    end

    # -> Session
    # Opens the Session; logs the instance's _user_ in to the instance's
    # _collection_.
    def open
      @user.log_in(@collection)
      @active = true
      self
    end

    # -> +true+ or +false+
    # Returns +true+ if the Session is open.
    def open?
      @active
    end

    # -> Model::Agent
    # Returns the Model::Agent for the Model::User in the Model::Division that
    # _@collection_ belongs to.
    def session_agent
      user.logged_in_agent
    end
  end
end
