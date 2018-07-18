# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for preparations.
    class RecordSetItem < Sequel::Model(:recordsetitem)
      many_to_one :record_set, key: :RecordSetID
      many_to_one :collection_object, key: :RecordId

      def before_create
        self.OrderNumber = record_set.next_order_number
        super
      end
    end
  end
end
