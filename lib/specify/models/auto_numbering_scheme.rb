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

      # -> Class
      # Returns the model class using the numbering scheme
      # (e.g. Specify::Model::CollectionObject).
      def scheme_model
        case self.TableNumber
        when 1
          CollectionObject
        when 7
          Accession
        end
      end

      # -> Symbol
      # Returns the kind of numbering scheme (e.g. :catalog_number).
      def scheme_type
        case self.SchemeName
        when 'Catalog Numbering Scheme'
          :catalog_number
        when 'Accession Numbering Scheme'
          :accession_number
        else
          :custom
        end
      end

      # -> String
      # Returns the currently highest number in the scheme.
      def max
        if scheme_model == CollectionObject && scheme_type == :catalog_number
          collections.map { |col| col.highest_catalog_number }
                     .max
        end
      end

      # -> String
      # Returns the next available number formatted according to the scheme.
      def increment
        @number_format ||= number_format
        @number_format.create(@number_format.incrementer(max) + 1)
      end

      # -> Specify::NumberFormat
      # Returns a NumberFormat instance for the AutoNumberingScheme.
      def number_format
        # TODO: get proper number format from xml
        case self.FormatName
        when 'CatalogNumberNumeric'
          NumberFormat.new
        end
      end
    end
  end
end
