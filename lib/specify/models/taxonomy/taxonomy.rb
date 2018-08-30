# frozen_string_literal: true

module Specify
  module Model
    # Taxnomy is the _tree_ class for the <em>taxonomy tree</em>. Taxonomies
    # hold all Specify::Model::Rank and Specify::Model::Taxon instances
    # belonging to a taxonomy used by a Specify::Model::Discipline.
    class Taxonomy < Sequel::Model(:taxontreedef)
      include TreeQueryable
      include Updateable

      one_to_many :disciplines,
                  key: :TaxonTreeDefID
      one_to_many :ranks,
                  key: :TaxonTreeDefID
      one_to_many :names,
                  class: 'Specify::Model::Taxon',
                  key: :TaxonTreeDefID
    end
  end
end
