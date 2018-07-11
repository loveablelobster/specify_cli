# frozen_string_literal: true

#
module Specify
  #
  class UserType
    attr_writer :view_set_dir
    attr_reader :name

    def initialize(name)
      @name = name.downcase
      @view_set_dir = nil
      valid?
    end

    # _values_ a hash
    def add_app_resource_dir(values)
      Model::AppResourceDir.create values
    end

    def save; end

    # Returns the AppResourceDir for the user type for a given Collection
    def view_set_dir(collection)
      Model::AppResourceDir.first(collection: collection,
                                  discipline: collection.discipline,
                                  UserType: @name.to_s,
                                  IsPersonal: false)
    end

    # Returns the user's ViewSetObject for _collection_.
    def view_set(collection)
      view_set_dir(collection)&.view_set_object
    end

    private

    def valid?
      %w[fullaccess guest limitedaccess manager].include? @name
    end
  end
end
