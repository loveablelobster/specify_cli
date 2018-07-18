# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for Collection Object record sets (only!).
    class RecordSet < Sequel::Model(:recordset)
      many_to_one :user, key: :SpecifyUserID
      many_to_one :collection,
                  class: 'Specify::Model::Collection',
                  key: :CollectionMemberID

      one_to_many :record_set_items, key: :RecordSetID

      many_to_many :collection_objects,
                   left_key: :RecordSetID,
                   right_key: :RecordId,
                   join_table: :recordsetitem

      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        self.TableID = 1 # For CollectionObject record sets
        self.Type = 0    # FIXME: guess
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      def highest_order_number
        record_set_items_dataset.max(:OrderNumber)
      end

      def next_order_number
        return 0 unless highest_order_number
        highest_order_number + 1
      end
    end
  end
end
