# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonEquivalents are finder objects
    class TaxonEquivalent
      # The id for the taxon record used by the web service.
      attr_reader :id

      # The URI of the web service used.
      # e.g. http://webservice.catalogueoflife.org/col/webservice
      attr_reader :service_url

      # The Specify::Model::Taxonomy.
      attr_reader :taxonomy

      # +id+ is a CatalogOfLife TaxonRespeonse #id
      # +vals+ is a hash for parameters to find the taxon by in case it does
      # not have an id.
      def initialize(taxonomy, id = nil, vals = {})
        @id = id
        @service_url = CatalogueOfLife::URL
        @taxonomy = taxonomy
        @taxon = find_by_id(id) || find_by_values(vals)
      end

      def create(vals)
        vals[:Source] = service_url
        vals[:TaxonomicSerialNumber] = id
        # TODO: find the parent
        taxonomy.add_name(vals)
      end

      def find_by_id(id)
        taxonomy.names_dataset.first(Source: service_url,
                                     TaxonomicSerialNumber: id)
      end

      def find_by_values(vals)
        results = taxonomy.names_dataset.find(vals)
        return results.first if results.size == 1
        raise 'Multiple matches' if results.size > 1
      end
    end
  end
end
