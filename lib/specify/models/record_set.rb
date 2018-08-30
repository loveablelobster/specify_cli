# frozen_string_literal: true

module Specify
  module Model
    # RecordSets are groups of records of certain classes in the Specify::Model,
    # for example Specify::Model::CollectionObject (currently the only supported
    # class for record sets).
    #
    # A RecordSet ontains Specify::Model::RecordSetItem instances. The items are
    # ordered in the RecordSet, and the order is determined bu the
    # Specify::Model::RecordSetItem#order_number.
    class RecordSet < Sequel::Model(:recordset)
      include Createable
      include Updateable

      many_to_one :user,
                  key: :SpecifyUserID
      many_to_one :collection,
                  class: 'Specify::Model::Collection',
                  key: :CollectionMemberID
      one_to_many :record_set_items,
                  key: :RecordSetID
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

      # Sequel hook that sets the _TableID_ that determines the kind of record
      # set (currently, only record sets of Specify::Model::CollectionObject
      # instances are supported - _TableID_ = +1+). Also sets the _Type_.
      def before_create
        self[:TableID] = 1
        self[:Type] = 0 # FIXME: guess
        super
      end

      # Returns the highest order number of items in +self+.
      def highest_order_number
        record_set_items_dataset.max(:OrderNumber)
      end

      # Returns the order number for the next item added to +self+
      def next_order_number
        return 0 unless highest_order_number
        highest_order_number + 1
      end
    end
  end
end
