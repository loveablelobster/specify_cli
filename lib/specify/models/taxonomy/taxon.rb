# frozen_string_literal: true

module Specify
  module Model
    # Taxon is the _item_ class for the Specify::Model::Taxonomy _tree_. A
    # Taxon holds information about the items to be classified, i.e. concepts
    # of taxonomic names. Each Taxon belongs to a Specify::Model::Rank, that
    # represents its formal Linnean classification rank.
    #
    # A Taxon has a _parent_ (another instance of Taxon) unless it is the root
    # taxon of the _tree_ and can have _children_ (other instances of Taxon).
    class Taxon < Sequel::Model(:taxon)
      include Createable
      include Updateable

      many_to_one :taxonomy,
                  key: :TaxonTreeDefID
      many_to_one :rank,
                  key: :TaxonTreeDefItemID
      many_to_one :parent,
                  class: self,
                  key: :ParentID
      many_to_one :accepted_name,
                  class: self,
                  key: :AcceptedID
      one_to_many :synonyms,
                  class: self,
                  key: :AcceptedID
      one_to_many :children,
                  class: self,
                  key: :ParentID
      one_to_many :common_names,
                  key: :TaxonID

      # Assigns new instances that are created from a Specify::Model::Rank to
      # the rank's Specify::Model::Taxonomy. Assigns a GUID for the record.
      def before_create
        self.taxonomy = rank&.taxonomy || parent.rank&.taxonomy
        self[:GUID] = SecureRandom.uuid
        super
      end

      # Returns +true+ if +self+ has _children_.
      def children?
        !children.empty?
      end

      # Returns a String with the taxon name.
      def name
        self[:Name]
      end
    end
  end
end
