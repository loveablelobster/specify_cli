# frozen_string_literal: true

require_relative 'catalogue_of_life/equivalent'
require_relative 'catalogue_of_life/lineage'
require_relative 'catalogue_of_life/rank'
require_relative 'catalogue_of_life/request'
require_relative 'catalogue_of_life/taxon'
require_relative 'catalogue_of_life/synonym'
require_relative 'catalogue_of_life/tree_crawler'

require 'erb'
require 'ostruct'

module Specify
  #
  module CatalogueOfLife
    # The base URL for the Service as a String.
    URL = 'http://www.catalogueoflife.org/'

    # The route for the api as a String.
    API_ROUTE = 'col/webservice'

    # Error that is raised when a Rank is initialized with an invalid name.
    class InvalidRankError < StandardError
      def initialize(msg = nil, rank: nil)
        msg ||= "Invalid taxon rank #{rank}"
      end
    end

    # Error that is raised when a Request returns ambiguous or no results.
    class ResponseError < StandardError
      # Request that caused the exception to be raised.
      attr_reader :request

      def initialize(msg = nil, request: nil)
        @request = nil
        super msg
      end
    end

    # Error that is raised when a Request returns ambiguous results.
    class AmbiguousResultsError < ResponseError
      # Results returned by the reuest that caused the exception to be raised.
      attr_reader :results

      def initialize(msg = nil, request: nil, results: nil)
        msg ||= "Amibiguous response. Request with params #{request.params}"\
                " returned multiple matches: #{results}"
        super msg, request: request
      end
    end

    # Error that is raised when a Request returns no results.
    class NotFoundError < ResponseError
      def initialize(msg = nil, request: nil)
        msg ||= 'Taxon not found in CatalogueOfLife. Request with params'\
                " #{request.params} returned no matches."
        super msg, request: request
      end
    end

    # Stop gap error to prevent a Catalogue Of Life issue.
    class ServiceReliabilityError < StandardError
      def initialize(msg = nil)
        msg ||= ' Subgenus queries are broken in CatalogueOfLife  and can lead'\
                ' to spurious results.'
        super msg
      end
    end
  end
end
