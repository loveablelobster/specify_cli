# frozen_string_literal: true

module Specify
  module Model
    #
    class Collection < Sequel::Model(:collection)
      many_to_one :discipline, key: :DisciplineID

      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      # Returns a string containing a human-readable representation.
      def inspect
        "#{self} name: #{self.CollectionName}"
      end

      # Returns the AppResourceDir instances.
      # The argument is only for ducktyping/overloading.
      def app_resource_dirs(_collection = nil)
        AppResourceDir.where(collection: self,
                             discipline: self.discipline,
                             UserType: nil,
                             IsPersonal: false)
      end

      # Returns the ViewSetObject.
      # The argument is only for ducktyping/overloading.
      def view_set(_collection = nil)
        ViewSetObject.first(app_resource_dir: app_resource_dirs)
      end
    end
  end
end
