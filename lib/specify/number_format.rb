# frozen_string_literal: true

module Specify
  # A class to work with Specify number formats.
  class NumberFormat
    attr_accessor :incrementer_length

    def initialize(incrementer_length = 9, options = {})
      @incrementer_length = incrementer_length
      @options = options
    end

    def self.parse(format_string)

    end

    def self.from_xml(format_node)

    end

    def create(number)
      if numeric?
        number.to_s.rjust(incrementer_length, '0')
      end
    end

    # -> Integer
    # Returns the incrementing numeric part of the full catalog number String.
    # _number_: the full Specify catalog number as String.
    def incrementer(number_string)
      return number_string.to_i if numeric?
    end

    # -> true or false
    # Returns +true+ if the NumberFormat is numeric.
    def numeric?
      @options.empty?
    end

    # -> String
    # Returns a template string for the CatalogNumber, where +#+ mark integer
    # digits of the incrementer.
    def template
      return '#' * incrementer_length if numeric?
    end

    # -> Regexp
    # Returns a regular expression to match the
    def to_regexp
      return /^(?<incrementer>\d{#{incrementer_length}})$/ if numeric?
    end
  end
end

# formats are in spappresourcedata
# referenced by spappresource with 'description' == 'UIFormatters',
# referencing spappresourcedir, referencing discipline
# if not persisted, file is in Specify/config/backstop/uiformatters.xml
#
# <?xml version="1.0" encoding="UTF-8"?>
# <formats>
#   <format system="true" name="AccessionNumber" class="edu.ku.brc.specify.datamodel.Accession" fieldname="accessionNumber" default="true">
#   <autonumber>edu.ku.brc.specify.dbsupport.AccessionAutoNumberAlphaNum</autonumber>
#     <field type="year" size="4" value="YEAR" byyear="true"/>
#     <field type="separator" size="1" value="-"/>
#     <field type="alphanumeric" size="2" value="AA"/>
#     <field type="separator" size="1" value="-"/>
#     <field type="numeric" size="3" inc="true"/>
#   </format>
#   <format system="false" name="ShipmentNumber" class="edu.ku.brc.specify.datamodel.Shipment" fieldname="shipmentNumber">
#   <autonumber>edu.ku.brc.af.core.db.AutoNumberGeneric</autonumber>
#     <field type="year" size="4" value="YEAR" byyear="true"/>
#     <field type="separator" size="1" value="-"/>
#     <field type="constant" size="2" value="VP"/>
#     <field type="separator" size="1" value="-"/>
#     <field type="numeric" size="3" inc="true"/>
#   </format>
#   <format system="true" name="CatalogNumberNumeric" class="edu.ku.brc.specify.datamodel.CollectionObject" fieldname="catalogNumber" default="false" length="9">
#   <autonumber>edu.ku.brc.specify.dbsupport.CollectionAutoNumber</autonumber>
#     <external>edu.ku.brc.specify.ui.CatalogNumberUIFieldFormatter</external>
#   </format>
#   <format system="false" name="CatalogNumber" class="edu.ku.brc.specify.datamodel.CollectionObject" fieldname="catalogNumber">
#   <autonumber>edu.ku.brc.specify.dbsupport.CollectionAutoNumberAlphaNum</autonumber>
#     <field type="year" size="4" value="YEAR"/>
#     <field type="separator" size="1" value="-"/>
#     <field type="numeric" size="6" inc="true"/>
#   </format>
#   <format system="false" name="CatalogNumberAlphaNumByYear" class="edu.ku.brc.specify.datamodel.CollectionObject" fieldname="catalogNumber">
#   <autonumber>edu.ku.brc.specify.dbsupport.CollectionAutoNumberAlphaNum</autonumber>
#     <field type="year" size="4" value="YEAR" byyear="true"/>
#     <field type="separator" size="1" value="-"/>
#     <field type="numeric" size="6" inc="true"/>
#   </format>
# </formats>
