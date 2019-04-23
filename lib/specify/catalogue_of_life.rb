# frozen_string_literal: true

require_relative 'catalogue_of_life/equivalent'
require_relative 'catalogue_of_life/lineage'
require_relative 'catalogue_of_life/rank'
require_relative 'catalogue_of_life/request'
require_relative 'catalogue_of_life/taxon'
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

    # RankError is a module that contains errors relating to taxonomic ranks.
    module RankError
      INVALID_RANK = 'Invalid taxon rank'
    end

    module ResponseError
      AMBIGUOUS_RESULTS = 'Amibiguous response.'\
                          ' Request returned multiple matches'
      NOT_FOUND = 'Taxon not found in CatalogueOfLife'
      SERVICE_RELIABILITY = 'Subgenus queries are broken in CatalogueOfLife'\
                            ' and can lead to spurious results. They are not'\
                            ' supported.'
    end
  end
end
