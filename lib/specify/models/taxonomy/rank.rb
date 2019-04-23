# frozen_string_literal: true

module Specify
  module Model
    # Rank is the _rank_ class for the Specify::Model::Taxonomy _tree_. A
    # Rank holds information about a formal Linnean classification rank in
    # a <em>taxonomic tree</em>.
    #
    # A Rank has a _parent_ (another instance of Rank) unless it is the root
    # rank of the _tree_ and can have one _child_ (another instance of Rank).
    class Rank < Sequel::Model(:taxontreedefitem)
      include Comparable
      include Updateable

      many_to_one :taxonomy,
                  key: :TaxonTreeDefID
      one_to_many :taxa,
                  key: :TaxonTreeDefItemID
      one_to_one :child,
                 class: self,
                 key: :ParentItemID
      many_to_one :parent, class: self,
                  key: :ParentItemID

      def <=>(other)
        self[:RankID] <=> other[:RankID]
      end

      # Where rank class could be Specify::CatalogueOfLife::TaxonRank
      def equivalent(rank_class)
        # Specify::CatalogueOfLife::TaxonRank.new name
      end

      def inspect
        "#<Specify::Model::Rank @name=#{name}"
      end

      # Returns a String with the name of the formal Linnean classification
      # rank.
      def name
        self[:Name]
      end
    end
  end
end
