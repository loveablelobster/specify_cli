# frozen_string_literal: true

module Specify
  module Model
    #
    class Accession < Sequel::Model(:accession)
      many_to_one :division, key: :DivisionID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        # TODO: set created_by
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        # TODO: set modified_by
        super
      end

      def number
        self.AccessionNumber
      end
    end
  end
end
