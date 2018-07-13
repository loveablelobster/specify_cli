# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for taxonomic ranks.
    class Rank < Sequel::Model(:taxontreedefitem)
      many_to_one :taxonomy, key: :TaxonTreeDefID
      one_to_many :taxa, key: :TaxonTreeDefItemID

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
