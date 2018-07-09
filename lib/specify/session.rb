# frozen_string_literal: true

require 'observer'

module Specify
  #
  class Session
    include Observable

    attr_reader :collection, :user, :active

    def initialize(user, collection)
      @user = Model::User.first(Name: user)
      @collection = Model::Collection.first(CollectionName: collection)
      @active = false
    end

    # Returns a string containing a human-readable representation of Session.
    def inspect
      "#{self} specify user: #{@user}"\
      ", collection: #{@collection}, open: #{@active}"
    end

    def close
      @user.log_out
      @active = false
      changed
      notify_observers(self)
      self
    end

    def open
      @user.log_in(@collection)
      @active = true
      self
    end

    def open?
      @active
    end

    def session_agent
      user.logged_in_agent
    end
  end
end
