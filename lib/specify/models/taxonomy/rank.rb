# frozen_string_literal: true

module Specify
  module Model
    #
    class Rank < Sequel::Model(:taxontreedefitem)
      many_to_one :taxonomy, key: :TaxonTreeDefID
      one_to_many :taxa, key: :TaxonTreeDefItemID
    end
  end
end
