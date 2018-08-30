# frozen_string_literal: true

module Specify
  module Model
    # CommonNames are vernacular names for a Specify::Model::Taxon.
    class CommonName < Sequel::Model(:commonnametx)
      include Createable
      include Updateable

      many_to_one :taxon,
                  key: :TaxonID
    end
  end
end
