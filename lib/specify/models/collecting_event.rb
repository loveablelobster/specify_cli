# frozen_string_literal: true

module Specify
  module Model
    # CollectingEvents hold information about when, where, how, and by whom a
    # Specify::Model::CollectionObject was collected.
    #
    # A CollectingEvent takes place in (has one) Specify::Model::Locality
    # (_where_ it was collected).
    #
    # A CollectingEvent can have one or many #collection_objects, depending
    # on the value of Specify::Model::Collection#embedded_collecting_event? for
    # the collection an associated CollectionObject belongs to.
    class CollectingEvent < Sequel::Model(:collectingevent)
      include Createable
      include Updateable

      many_to_one :discipline,
                  key: :DisciplineID
      many_to_one :locality,
                  key: :LocalityID
      one_to_many :collection_objects,
                  key: :CollectingEventID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Sequel hook that assigns a GUID.
      def before_create
        self[:GUID] = SecureRandom.uuid
        super
      end
    end
  end
end
