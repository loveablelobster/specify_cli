# frozen_string_literal: true

module Specify
  # A UserType represents a lvel to which _.views.xml_ files can be uploaded.
  # This is the only level that is not represented by a proper Model class,
  # the others being Specify::Model::Collection, Specify::Model::Discipline,
  # and Specify::Model::User. Like the model classes, a UserType implements
  # #view_set_dir and #view_set to give access to the correct
  # Specify::Model::AppResourceDir and Specify::Model::ViewSetObject instances.
  class UserType
    # The Specify::Model::AppResourceDir associated with +self+
    attr_writer :view_set_dir

    # A String, must be either +manager+, +fullaccess+, +limitedaccess+, or
    # +guest+
    attr_reader :name

    # Returns a new UserType.
    # +name+ must be a valid #name.
    def initialize(name)
      @name = name.downcase
      @view_set_dir = nil
      valid?
    end

    # Returns a new instance of Specify::Model::AppResourceDir with +values+.
    def add_app_resource_dir(values)
      Model::AppResourceDir.create values
    end

    # Returns +self+.
    #
    # This is a dummy method to allow use as a Specify::ViewLoader#target
    # alongside Specify::Model::Collection, Specify::Model::Discipline, and
    # Specify::Model::User.
    def save
      self
    end

    # Returns +true+ if #name is any of +fullaccess+, +guest+, +limitedaccess+,
    # or +manager+; +false+ otherwise.
    def valid?
      %w[fullaccess guest limitedaccess manager].include? @name
    end

    # Returns the Specify::Model::AppResourceDir for this user type (#name) in
    # +collection+ (a Specify::Model::Collection).
    def view_set_dir(collection)
      Model::AppResourceDir.first(collection: collection,
                                  discipline: collection.discipline,
                                  UserType: @name.to_s,
                                  IsPersonal: false)
    end

    # Returns the Specify::Model::ViewSetObject for this user type +collection+
    # (a Specify::Model::Collection).
    def view_set(collection)
      view_set_dir(collection)&.view_set_object
    end
  end
end
