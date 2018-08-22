# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for preparations.
    class Preparation < Sequel::Model(:preparation)
      many_to_one :collection_object, key: :CollectionObjectID
      many_to_one :collection,
                  class: 'Specify::Model::Collection',
                  key: :CollectionMemberID
      many_to_one :preparation_type, key: :PrepTypeID
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
        super
      end

      def count
        self.CountAmt
      end
    end
  end
end
