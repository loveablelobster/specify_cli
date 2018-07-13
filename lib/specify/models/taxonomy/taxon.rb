# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for taxa
    class Taxon < Sequel::Model(:taxon)
      many_to_one :taxonomy, key: :TaxonTreeDefID
      many_to_one :rank, key: :TaxonTreeDefItemID
      many_to_one :parent, key: :ParentID, class: self
      one_to_many :children, key: :ParentID, class: self
      one_to_many :common_names, key: :TaxonID

      # create: rank.add_taxon or parent.add_child
      def before_create
        self.taxonomy = rank&.taxonomy || parent.rank&.taxonomy
        self.Version = 0
        self.TimestampCreated = Time.now
        self.GUID = SecureRandom.uuid
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      def children?
        !children.empty?
      end
    end
  end
end
