# frozen_string_literal: true

module Specify
  module Model
    #
    class AutoNumberingScheme < Sequel::Model(:autonumberingscheme)
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID
      many_to_many :collections,
                   left_key: :AutoNumberingSchemeID,
                   right_key: :CollectionID,
                   join_table: :autonumsch_coll
      many_to_many :disciplines,
                   left_key: :AutoNumberingSchemeID,
                   right_key: :DisciplineID,
                   join_table: :autonumsch_dsp
      many_to_many :divisions,
                   left_key: :AutoNumberingSchemeID,
                   right_key: :DivisionID,
                   join_table: :autonumsch_div

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
    end
  end
end
