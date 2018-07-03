# frozen_string_literal: true

module Specify
  module Model
    #
    class CollectionObject < Sequel::Model(:collectionobject)
      many_to_one :collection, key: :CollectionID
      many_to_one :collection_member,
                  class: 'Specify::Model::Collection',
                  key: :CollectionMemberID
      many_to_one :cataloger,
                  class: 'Specify::Model::Agent',
                  key: :CatalogerID
      many_to_one :collecting_event, key: :CollectingEventID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        self.collection_member = self.collection
        # TODO: block to fill catalog number
        self.CatalogedDate = Date.today
        self.CatalogedDatePrecision = 1
        self.GUID = SecureRandom.uuid
        self.collecting_event = embed_collecting_event(self.collection)

        # TODO: block to set cataloger (logged in user or from arg)
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        # TODO: set modified_by
        super
      end

      def embed_collecting_event(collection)
        return unless collection.IsEmbeddedCollectingEvent
        Specify::Model::CollectingEvent.create discipline: collection.discipline
      end
    end
  end
end
