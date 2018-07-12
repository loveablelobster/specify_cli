# frozen_string_literal: true

module Specify
  module Model
    #
    class Taxon < Sequel::Model(:taxon)
      many_to_one :taxonomy, key: :TaxonTreeDefID
      many_to_one :rank, key: :TaxonTreeDefItemID
      many_to_one :parent, key: :ParentID, class: self
      one_to_many :children, key: :ParentID, class: self
      one_to_many :common_names, key: :TaxonID

      def children?
        !children.empty?
      end
    end
  end
end
