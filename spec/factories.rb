module Factories
  module CatalogueOfLife
    module Taxon
      def self.with(sym)
        result = Psych.load_file('spec/support/taxon_response.yaml').fetch sym
        ::Specify::CatalogueOfLife::Taxon.new result
      end
    end
  end

  module Model
    module Taxonomy
      def self.for_tests
        ::Specify::Model::Taxonomy.first
      end
    end
    module Rank
      def self.order
        ::Specify::Model::Rank.first Name: 'Order'
      end

      def self.family
        ::Specify::Model::Rank.first Name: 'Family'
      end

      def self.genus
        ::Specify::Model::Rank.first Name: 'Genus'
      end

      def self.species
        ::Specify::Model::Rank.first Name: 'Species'
      end
    end

    module Taxon
      def self.order
        ::Specify::Model::Taxon
          .first(Name: 'Trilobita')
          .add_child  Name: 'Agnostida',
                      rank: Rank.order,
                      Author: 'Salter, 1864',
                      IsAccepted: true,
                      IsHybrid: false,
                      RankID: Rank.order.RankID,
                      taxonomy: Taxonomy.for_tests
      end

      def self.family
        Taxon.order
             .add_child Name: 'Agnostida',
                        rank: Rank.family,
                        Author: 'McCoy, 1849',
                        IsAccepted: true,
                        IsHybrid: false,
                        RankID: Rank.family.RankID,
                        taxonomy: Taxonomy.for_tests
      end

      def self.genus
        Taxon.family
             .add_child Name: 'Entomostracites',
                        rank: Rank.genus,
                        IsAccepted: false,
                        IsHybrid: false,
                        RankID: Rank.genus.RankID,
                        taxonomy: Taxonomy.for_tests
      end

      def self.species
        Taxon.genus
             .add_child Name: 'pisiformis',
                        rank: Rank.species,
                        Author: 'Wahlenberg, 1818',
                        IsAccepted: false,
                        IsHybrid: false,
                        RankID: Rank.species.RankID,
                        taxonomy: Taxonomy.for_tests
      end
    end
  end
end
