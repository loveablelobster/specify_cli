# frozen_string_literal: true

module Specify
  # A class that represents a lvel for upload of views.
  class UserType
    attr_writer :view_set_dir

    # A String, must be either 'manager', 'fullaccess', 'limitedaccess', or
    # 'guest'
    attr_reader :name

    # -> UserType
    # Creates a new instance.
    def initialize(name)
      @name = name.downcase
      @view_set_dir = nil
      valid?
    end

    # -> Model::AppResourceDir
    # Creates a new instance of Model::AppResourceDir with _values_.
    # _values_: a Hash with attributes and values to create a
    #           Model::AppResourceDir
    def add_app_resource_dir(values)
      Model::AppResourceDir.create values
    end

    # -> UserType
    # Dummy method to allow duck typing use alongside Model::Collection,
    # Model::Discipline, and Model::User.
    def save
      self
    end

    # -> +true+ or +false+
    # Returns +true+ if the user type name is any of 'fullaccess', 'guest',
    # 'limitedaccess', or 'manager'; +false+ otherwise.
    def valid?
      %w[fullaccess guest limitedaccess manager].include? @name
    end

    # -> Model::AppResourceDir
    # Returns the instance's Model:: AppResourceDir for _collection_.
    # _collection_: a Model::Collection.
    def view_set_dir(collection)
      Model::AppResourceDir.first(collection: collection,
                                  discipline: collection.discipline,
                                  UserType: @name.to_s,
                                  IsPersonal: false)
    end

    # -> Model::ViewSetObject
    # Returns the instance's Model::ViewSetObject for _collection_.
    # _collection_: a Model::Collection.
    def view_set(collection)
      view_set_dir(collection)&.view_set_object
    end
  end
end
