# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # Synonyms wrap CatalogueOfLife responses for synonyms and provide
    # standard Taxon like behavior.
    class Synonym < Taxon
      def initialize
        super
      end
    end
  end
end
