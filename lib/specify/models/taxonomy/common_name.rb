# frozen_string_literal: true

module Specify
  module Model
    #
    class CommonName < Sequel::Model(:commonnametx)
      many_to_one :taxon, key: :TaxonID
    end
  end
end
