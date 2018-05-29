# frozen_string_literal: true

#
module SpResource
  #
  class UserType
    def initialize(name)
      @name = name.downcase
      valid?
    end

    # Returns the AppResourceDir for the user type for a given Collection
    def app_resource_dirs(collection)
      Specify::Model::AppResourceDir.where(collection: collection,
                                           discipline: collection.discipline,
                                           UserType: @name,
                                           IsPersonal: false)
    end

    # Returns the user's ViewSetObject for _collection_.
    def view_set(collection)
      # FIXME: this works, but would be more coherent if also could use assoc
      dirs = app_resource_dirs(collection).map(&:SpAppResourceDirID)
      Specify::Model::ViewSetObject.first(SpAppResourceDirID: dirs)
    end

    private

    def valid?
      %w[manager guest].include? @name
    end
  end
end
