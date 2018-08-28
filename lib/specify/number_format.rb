# frozen_string_literal: true

module Specify
  # NumberFormats represent auto numbering formatters in a Specify::Database.
  # Number formats in _Specify_ are applied to Strings, to ensure they conform
  # to a defined format.
  #
  # If the NumberFormat can be auto-incremented, it will have a serial number
  # part, the _incrementer_.
  class NumberFormat
    # The number of digits (length) of the serial number part.
    attr_accessor :incrementer_length

    # Not implemented
    def self.from_xml(format_node)
      # TODO: implement
    end

    # Returns a new NumberFormat
    #
    # +options+ is not implemented; if empty, the NumberFormat will be numeric,
    # i.e. consist only of the _incrementer_.
    def initialize(incrementer_length = 9, options = {})
      @incrementer_length = incrementer_length
      @options = options
    end

    # Not implemented
    def self.parse(format_string)
      # TODO: implement
    end

    # Returns a new formatted String for +number+
    def create(number)
      number.to_s.rjust(incrementer_length, '0') if numeric?
    end

    # Returns the serial number part (_incrementer_) of the formatted
    # +number_string+.
    def incrementer(number_string)
      return number_string.to_i if numeric?
    end

    # Returns +true+ if the +self+ is a numeric NumberFormat.
    def numeric?
      @options.empty?
    end

    # Returns a String template for +self+, where # marks a digit of the
    # _incrementer_ (serial number part).
    def template
      return '#' * incrementer_length if numeric?
    end

    # Returns a Regexp to match the match the _incrementer_ in the NumberFormat.
    def to_regexp
      return /^(?<incrementer>\d{#{incrementer_length}})$/ if numeric?
    end
  end
end
