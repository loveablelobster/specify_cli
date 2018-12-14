# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonEquivalents are finder objects that wrap TaxonResponeses and find
    # their equivalent in the Specify database
    class TaxonEquivalent
      # The id for the taxon record used by the web service.
      attr_reader :concept

      # The URI of the web service used.
      # e.g. http://webservice.catalogueoflife.org/col/webservice
      attr_reader :service_url

      # The Specify::Model::Taxonomy.
      attr_reader :taxonomy

      # FIXME: should be initialized with a taxon response, extract id
      # +id+ is a CatalogOfLife TaxonRespeonse #id
      # +vals+ is a hash for parameters to find the taxon by in case it does
      # not have an id.
      def initialize(taxonomy, response = nil)
        @concept = response
        @service_url = CatalogueOfLife::URL
        @taxonomy = taxonomy
#         @taxon = find_by_id(id) || find_by_values(vals)
      end

      def create(vals)
        vals[:Source] = service_url
        vals[:TaxonomicSerialNumber] = id
        # TODO: find the parent
        taxonomy.add_name(vals)
      end

      def find_by_id(id)
        taxonomy.names_dataset.first(Source: service_url,
                                     TaxonomicSerialNumber: concept.id)
      end

      def find_by_values(vals)
        # FIXME: vals should by default be concept.name, concept.rank,
        #        parent
        results = taxonomy.names_dataset.find(vals)
        return results.first if results.size == 1
        raise 'Multiple matches' if results.size > 1
      end
    end
  end
end
