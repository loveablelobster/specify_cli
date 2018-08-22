# frozen_string_literal: true

module Specify
  module Model
    #
    class PreparationType < Sequel::Model(:preptype)
      many_to_one :collection, key: :CollectionID
      one_to_many :preparations, key: :PrepTypeID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        # TODO: set modified_by
        super
      end

      def name
        self.Name
      end
    end
  end
end
