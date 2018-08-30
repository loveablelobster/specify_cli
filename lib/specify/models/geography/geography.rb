# frozen_string_literal: true

module Specify
  module Model
    # Geography is the _tree_ class for the <em>geographic tree</em>.
    # Geographies hold all Specify::Model::AdministrativeDivision and
    # Specify::Model::GeographicName instances belonging to a geography used by
    # a Specify::Model::Discipline.
    class Geography < Sequel::Model(:geographytreedef)
      include TreeQueryable
      include Updateable

      one_to_many :disciplines,
                  key: :GeographyTreeDefID
      one_to_many :ranks,
                  class: 'Specify::Model::AdministrativeDivision',
                  key: :GeographyTreeDefID
      one_to_many :names,
                  class: 'Specify::Model::GeographicName',
                  key: :GeographyTreeDefID
    end
  end
end
