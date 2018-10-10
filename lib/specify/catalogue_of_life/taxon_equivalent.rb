# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonEquivalents are finder objects
    class TaxonEquivalent
      # The Specify::Model::Taxonomy
      attr_reader: taxonomy

      # +id+ is a CatalogOfLife TaxonRespeonse #id
      # +vals+ is a hash for parameters to find the taxon by in case it does
      # not have an id
      def initialize(taxonomy, id = nil, vals = {})
        @taxonomy = taxonomy
        @taxon = find_by_id(id) || find_by_values(vals)
      end

      def find_by_id(id)
        taxonomy.names_dataset
      end

      def find_by_values(id)

      end
    end
  end
end
