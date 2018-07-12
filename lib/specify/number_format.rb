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
      # TODO: implement
    end

    def self.from_xml(format_node)
      # TODO: implement
    end

    # -> String
    # Returns a new formatted number string for _number_
    def create(number)
      number.to_s.rjust(incrementer_length, '0') if numeric?
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
