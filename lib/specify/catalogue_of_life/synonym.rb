# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # Synonyms wrap CatalogueOfLife responses for synonyms and provide
    # standard Taxon like behavior.
    #
    # CoL synonyms do not have classification, but point to the accepted name,
    # which has.
    # Also genus has
    class Synonym < Taxon
      def initialize(col_result_hash)
        super
      end

      def classification(skip_subgenera: true)
        # TODO: needs spec for subspecies
        classification_source.classification(skip_subgenera: skip_subgenera)
      end

      def extinct?
        accepted_name.extinct?
      end

      private

      def classification_source
        syn_rank = rank < SPECIES ? :species : :genus
        if self.public_send(syn_rank) == accepted_name.public_send(syn_rank)
          accepted_name
        else
          Request.by(name: self.public_send(syn_rank), rank: syn_rank.to_s)
                 .taxon
        end
      rescue AmbiguousResultsError
        accepted_name
      end
    end
  end
end
