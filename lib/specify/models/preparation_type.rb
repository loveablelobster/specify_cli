# frozen_string_literal: true

module Specify
  module Model
    #
    class Preparation < Sequel::Model(:preparation)
      many_to_one :discipline, key: :DisciplineID
      many_to_one :collection_object, key: :CollectionObjectID
      many_to_one :collection, key: :CollectionID
      one_to_many :preparation_type, key: :PrepTypeID
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
    end
  end
end