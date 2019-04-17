module Factories
  module CatalogueOfLife
    module TaxonResponse
      def self.with(sym)
        result = Psych.load_file('spec/support/taxon_response.yaml').fetch sym
        ::Specify::CatalogueOfLife::TaxonResponse.new result
      end
    end
  end

  module Model
    module Taxonomy
      def self.for_tests
        ::Specify::Model::Taxonomy.first
      end
    end
  end
end
