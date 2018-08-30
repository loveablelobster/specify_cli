# frozen_string_literal: true

module Specify
  module Model
    # Collections are the lowest level of scope in a Specify::Database.
    #
    # A Collection belongs to the a Specify::Model::Discipline.
    #
    # A Collection contains all instances of Specify::Model::CollectionObject
    # belonging to that collection.
    class Collection < Sequel::Model(:collection)
      include Updateable

      many_to_one :discipline,
                  key: :DisciplineID
      one_to_many :collection_objects,
                  key: :CollectionID
      one_to_many :preparation_types,
                  key: :CollectionID
      one_to_many :record_sets,
                  key: :CollectionMemberID
      one_to_many :app_resource_dirs,
                  class: 'Specify::Model::AppResourceDir',
                  key: :CollectionID
      one_through_one :auto_numbering_scheme,
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

      # Returns +false+ if Specify::Model::CollectionObject instances in +self+
      # can share Specify::Model::CollectingEvent instances. +false+ otherwise.
      def embedded_collecting_event?
        self[:IsEmbeddedCollectingEvent]
      end

      # Returns the highest Specify::Model::CollectionObject#catalog_number
      # for collection_objects belonging to +self+.
      def highest_catalog_number
        collection_objects_dataset.max(:CatalogNumber)
      end

      # Creates a string representation of +self+.
      def inspect
        "#{self} name: #{self.CollectionName}"
      end

      # Returns a String that is the name of +self+.
      def name
        self[:CollectionName]
      end

      # Returns the Specify::Model::ViewSetObject that belongs to +self+.
      # The +_collection+ argument will be discared and is only there to allow
      # intances to be used as a Specify::Service::ViewLoader#target.
      def view_set(_collection = nil)
        view_set_dir&.view_set_object
      end
    end
  end
end
