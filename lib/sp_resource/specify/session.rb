# frozen_string_literal: true

require 'observer'

module SpResource
  module Specify
    #
    class Session
      include Observable

      attr_reader :database, :collection, :user

      def initialize(database, user, collection)
        @database = database
        add_observer(@database)
        @user = SpResource::Specify::Model::User.first(Name: user)
        @collection = Specify::Model::Collection.first(CollectionName: collection)
        @active = false
      end

      # Returns a string containing a human-readable representation of Session.
      def inspect
        "#{self} database: #{@database}, specify user: #{@user}"\
        ", collection: #{@collection}, open: #{@active}"
      end

      def close
        @user.logout
        @active = false
        changed
        notify_observers(self)
      end

      def open
        @user.login(@collection)
        @active = true
        @database << self
      end

      def open?
        @active
      end
    end
  end
end
