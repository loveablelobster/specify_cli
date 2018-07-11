# frozen_string_literal: true

#
module Specify
  #
  class UserType
    attr_reader :name

    def initialize(name)
      @name = name.downcase
      valid?
    end

    #
    def add_app_resource_dir

    end

    # Returns the AppResourceDir for the user type for a given Collection
    def view_set_dir(collection)
      Model::AppResourceDir.first(collection: collection,
                                  discipline: collection.discipline,
                                  UserType: @name,
                                  IsPersonal: false)
    end

    # Returns the user's ViewSetObject for _collection_.
    def view_set(collection)
      view_set_dir(collection).view_set_object
    end

    private

    def valid?
      %w[manager guest].include? @name
    end
  end
end
