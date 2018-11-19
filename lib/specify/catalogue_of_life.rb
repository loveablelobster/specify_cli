# frozen_string_literal: true

require_relative 'catalogue_of_life/taxon_equivalent'
require_relative 'catalogue_of_life/taxon_rank'
require_relative 'catalogue_of_life/taxon_request'
require_relative 'catalogue_of_life/taxon_response'
require_relative 'catalogue_of_life/tree_crawler'

module Specify
  #
  module CatalogueOfLife
    URL = 'http://webservice.catalogueoflife.org/col/webservice'
  end
end
