# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for geographies (geography trees).
    class Geography < Sequel::Model(:geographytreedef)
      one_to_many :disciplines, key: :GeographyTreeDefID
#       one_to_many :ranks, key: :TaxonTreeDefID
#       one_to_many :taxa, key: :TaxonTreeDefID

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      # ->
#       def rank(rank_name)
#         ranks_dataset.first(Name: rank_name.capitalize)
#       end
    end
  end
end
