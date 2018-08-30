# frozen_string_literal: true

module Specify
  module Model
    # RecordSetItems are orderd items in a Specify::Model::RecordSet.
    #
    # A RecordSetItem represents instances of Specify::Model classes that are
    # contained in a Specify::Model::RecordSet. The only class currently
    # supported is Specify::Model::CollectionObject.
    class RecordSetItem < Sequel::Model(:recordsetitem)
      many_to_one :record_set,
                  key: :RecordSetID
      many_to_one :collection_object,
                  key: :RecordId

      # Sequel hook that sets #order_number for newly created records.
      def before_create
        self[:OrderNumber] = record_set.next_order_number
        super
      end

      # Returns the index (an Integer) that marks the position of +self+ in a
      # Specify::Model::RecordSet.
      def order_number
        self[:OrderNumber]
      end
    end
  end
end
