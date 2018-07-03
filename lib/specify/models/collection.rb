# frozen_string_literal: true

module Specify
  module Model
    #
    class Collection < Sequel::Model(:collection)
      many_to_one :discipline, key: :DisciplineID
      one_to_many :collection_objects, key: :CollectionID

      one_to_many :app_resource_dirs,
                  class: 'Specify::Model::AppResourceDir',
                  key: :CollectionID

      many_to_many :auto_numbering_schemes,
                   left_key: :CollectionID,
                   right_key: :AutoNumberingSchemeID,
                   join_table: :autonumsch_coll

      one_to_one :view_set_dir,
                 class: 'Specify::Model::AppResourceDir',
                 key: :CollectionID do |ds|
                   ds.where(discipline: discipline,
                            UserType: nil,
                            IsPersonal: false)
                 end

      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      # Returns a string containing a human-readable representation.
      def inspect
        "#{self} name: #{self.CollectionName}"
      end

      # Returns the ViewSetObject.
      # The argument is only for ducktyping/overloading.
      def view_set(_collection = nil)
        view_set_dir.view_set_object
      end
    end
  end
end
