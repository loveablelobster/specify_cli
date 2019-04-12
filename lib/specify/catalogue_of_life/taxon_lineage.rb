# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonLineages hold an Array of TaxonEquivalent instances for the
    # classification of a TaxonResponse.
    class TaxonLineage
      # Returns an array of TaxonEquivalents ordered by #rank, starting with
      # the highest rank.
      attr_reader :ancestors

      # Returns the TaxonEquivalent in lineage that is persisted in the
      # database.
      attr_reader :known_ancestor

      # Returns an array of TaxonEquivalents that are missing in the database.
      attr_accessor :missing_ancestors

      def initialize(taxon_classification, taxonomy)
        @ancestors = fetch_ancestors taxon_classification, taxonomy
        @missing_ancestors = []
        @known_ancestor = find_known_ancestor
      end

      # Creates Model::Taxon instances for
      def create
        raise 'Creation with unknown root not implemented' unless known_ancestor

        missing_classification.map do |taxon|
          missing_ancestors.delete taxon
          taxon.create
        end
      end

      def classification
        ancestors.reverse
      end

      def missing_classification
        missing_ancestors.reverse
      end

      private

      def fetch_ancestors(taxon_classification, taxonomy)
        taxon_classification.map { |t| TaxonEquivalent.new(taxonomy, t) }
                            .sort_by(&:rank)
      end

      def find_known_ancestor
        ancestors.find.with_index do |ancestor, i|
          match = ancestor.find(ancestors[i + 1])
          missing_ancestors << ancestor unless match
          match
        end
      end
    end
  end
end
