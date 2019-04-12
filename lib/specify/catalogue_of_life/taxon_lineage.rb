# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    class TaxonLineage
      # Returns an array of TaxonEquivalents ordered by #rank, starting with
      # the highest rank.
      attr_reader :ancestors

      # Returns the TaxonEquivalent in lineage that is persisted in the
      # database.
      attr_reader :known_ancestor

      # Returns an array of TaxonEquivalents that are missing in the database.
      attr_accessor :missing_ancestors

      def initialize(lineage_of_taxon_equivalents)
        @ancestors = lineage_of_taxon_equivalents.sort_by(&:rank)
        @missing_ancestors = []
        @known_ancestor = find_known_ancestor
      end

      # Creates Model::Taxon instances for
      def create
        if known_ancestor
          missing_classification.map do |taxon|
            missing_ancestors.delete taxon
            taxon.create
          end
        else
          raise 'Creation of unknown lineage not implemented' # FIXME: implement
        end
      end

      def classification
        ancestors.reverse
      end

      def missing_classification
        missing_ancestors.reverse
      end

      private

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
