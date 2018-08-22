# frozen_string_literal: true

require 'observer'

module Specify
  # A Session is responsible for logging an existing Specify::Model::User in and
  # out of a Specify::Model::Collection. Session objects are used to set the
  # #created_by and #modified_by attributes for any record created or updated to
  # the session #user.
  class Session
    include Observable

    # +true+ if the session is open (the #user is logged in), +false+ otherwise.
    attr_reader :active

    # The Specify::Model::Collection that #user is logged in to during
    # the life span of the session.
    attr_reader :collection

    # The Specify::Model::Discipline that #user is logged in to during
    # the life span of the session.
    attr_reader :discipline

    # The Specify::Model::Division that #collection and #discipline belong to.
    attr_reader :division

    # The Specify::Model::User that is logged in to #collection during the
    # session.
    attr_reader :user

    # Returns a new Session.
    #
    # +user+ is a String with an existing Specify::Model::User#name.
    #
    # +collection+ is a String with and existing
    # Specify::Model::Collection#name.
    def initialize(user, collection)
      @user = Model::User.first(Name: user)
      @collection = Model::Collection.first(CollectionName: collection)
      @discipline = @collection.discipline
      @division = @discipline.division
      @active = false
    end

    # Creates a string representation of +self+.
    def inspect
      "#{self} specify user: #{@user}"\
      ", collection: #{@collection}, open: #{@active}"
    end

    # Closes this session, logs #user out of #collection.
    def close
      @user.log_out
      @active = false
      changed
      notify_observers(self)
      self
    end

    # Opens this session, logs #user in to #collection.
    def open
      @user.log_in(@collection)
      @active = true
      self
    end

    # Returns +true+ if this session is currently open.
    def open?
      @active
    end

    # Returns the Specify::Model::Agent for #user in #division.
    def session_agent
      user.logged_in_agent
    end
  end
end
