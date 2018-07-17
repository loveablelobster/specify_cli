# frozen_string_literal: true

module Specify
  module Model
    #
    class CollectingEvent < Sequel::Model(:collectingevent)
      many_to_one :discipline, key: :DisciplineID
      many_to_one :locality, key: :LocalityID

      one_to_many :collection_objects, key: :CollectingEventID

      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        self.GUID = SecureRandom.uuid
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        # TODO: set modified_by
        super
      end
    end
  end
end
