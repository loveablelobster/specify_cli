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

      def max
        collections.each do |col|
          col.collection_objects.each { |co| p co.CatalogNumber }
        end
      end

      def pattern
        case self.FormatName
        when 'CatalogNumberNumeric'
          /^\d{9}$/
        end
        # TODO: get proper number format and create pattern
      end
    end
  end
end

# formats are in spappresourcedata
# referenced by spappresource with 'description' == 'UIFormatters',
# referencing spappresourcedir, referencing discipline
# if not persisted, file is in Specify/config/backstop/uiformatters.xml
#
# <format system="true"
#         name="CatalogNumberNumeric"
#         class="edu.ku.brc.specify.datamodel.CollectionObject"
#         fieldname="catalogNumber"
#         default="false">
#     <autonumber>edu.ku.brc.specify.dbsupport.CollectionAutoNumber</autonumber>
#     <external>edu.ku.brc.specify.ui.CatalogNumberUIFieldFormatter</external>
# </format>
