# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for geographies (geography trees).
    class Geography < Sequel::Model(:geographytreedef)
      one_to_many :disciplines, key: :GeographyTreeDefID
      one_to_many :administrative_divisions, key: :GeographyTreeDefID
      one_to_many :geographic_names, key: :GeographyTreeDefID

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      # ->
      def administrative_division(division_name)
        administrative_divisions_dataset.first(Name: division_name.capitalize)
      end

      # ->
      # _hash_: { 'Highest Administrative division name' => 'Geographic name',
      #           ...
      #           'Lowest Administrative division name' => 'Geographic name' }
      # FIXME: This should be allowed to skip ranks that are not enforced
      def search_tree(hash)
        hash.reduce(nil) do |geo, (rank, name)|
          names = geo&.children_dataset || geographic_names_dataset
          div = administrative_division(rank)
          geo = names.first(Name: name, administrative_division: div)
        end
      end
    end
  end
end
