# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for taxonomies (taxon trees).
    class Taxonomy < Sequel::Model(:taxontreedef)
      include TreeQueryable

      one_to_many :disciplines, key: :TaxonTreeDefID
      one_to_many :ranks, key: :TaxonTreeDefID
      one_to_many :names,
                  class: 'Specify::Model::Taxon',
                  key: :TaxonTreeDefID

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
