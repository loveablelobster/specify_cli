# frozen_string_literal: true

module Specify
  module Model
    # AutoNumberingSchemes represent automatically incrementable numbers
    # (serial numbers such as catalog numbers or accession numbers).
    #
    # An AutoNumberingScheme is scoped to one or more #collections
    # (instances of Specify::Model::Collection) in the case of catalog numbers,
    # one or more #divisions (instances of Specify::Model::Division) in the case
    # of accession numbers. Serial numbers (_incrementers_) will be incremented
    # across that scope.
    #
    # An AutoNumberingScheme has a #number_format (an instance of
    # Specify::NumberFormat) that determines the format of the number
    # (auto-numbers in _Specify_ are strings).
    class AutoNumberingScheme < Sequel::Model(:autonumberingscheme)
      include Createable
      include Updateable

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

      # Returns +true+ if +self+ applies to catalog numbers.
      def catalog_number?
        scheme_model == CollectionObject && scheme_type == :catalog_number
      end

      # Returns the next available serial number in the scope of the scheme,
      # formatted according to the #number_format.
      def increment
        @number_format ||= number_format
        @number_format.create(@number_format.incrementer(max) + 1)
      end

      # Returns the currently highest number within the scope of self.
      # Currently only supports catalog numbers.
      def max
        raise 'not implemented' unless catalog_number?
        collections.map(&:highest_catalog_number).compact.max
      end

      # Returns the Specify::NumberFormat instance for the +self+.
      def number_format
        # TODO: get proper number format from xml
        case self.FormatName
        when 'CatalogNumberNumeric'
          NumberFormat.new
        end
      end

      # Returns the model class the numbering scheme applies to;
      # Specify::Model::CollectionObject for catalog numbers,
      # Specify::Model::Accession for accession numbers.
      def scheme_model
        case self.TableNumber
        when 1
          CollectionObject
        when 7
          Accession
        end
      end

      # Returns a symbol for the type of numbering scheme
      # (+:catalog_number+, +accession_number+, or +:custom+).
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
    end
  end
end
