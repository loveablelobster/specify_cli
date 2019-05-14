# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # Lineages hold an Array of Equivalent instances for the
    # classification of a Taxon.
    class Lineage
      # Returns an array of Equivalents ordered by #rank, starting with
      # the highest rank.
      attr_reader :ancestors

      # Returns the Equivalent in lineage that is persisted in the
      # database.
      attr_reader :known_ancestor

      # Returns an array of Equivalents that are missing in the database.
      attr_accessor :missing_ancestors

      # Creates a new instance. <em>taxon_classification</em> is an Array of
      # Equivalent instances, all linked in parent-child relationships, ordered
      # by Rank. _taxonomy_ is the Model::Taxonomy instance for the
      # Equivalent#internal taxa.
      def initialize(taxon_classification, taxonomy)
        @ancestors = fetch_ancestors taxon_classification, taxonomy
        @missing_ancestors = []
        @known_ancestor = find_known_ancestor
      end

      # Creates Model::Taxon instances for each taxon in
      # #missing_classification.
      def create
        raise 'Creation with unknown root not implemented' unless known_ancestor

        missing_classification.map do |taxon|
          missing_ancestors.delete taxon
          taxon.create
        end
      end

      # Retturns an Array of Equivalent instances in the lineage ordered by
      # rank.
      def classification
        ancestors.reverse
      end

      # Returns an Array of Equivalent instances for taxa in the lineage that
      # are missing from taxonomy.
      def missing_classification
        missing_ancestors.reverse
      end

      private

      def fetch_ancestors(taxon_classification, taxonomy)
        taxon_classification.map { |t| Equivalent.new(taxonomy, t) }
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
