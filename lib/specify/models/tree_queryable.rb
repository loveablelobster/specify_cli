# frozen_string_literal: true

module Specify
  module Model
    # Mixin that provides convienience methods for nested hierarchies.
    module TreeQueryable
      AMBIGUOUS_MATCH_ERROR = 'Ambiguous results during tree search'
      # ->
      def rank(rank_name)
        ranks_dataset.first(Name: rank_name.capitalize)
      end

      # ->
      # _hash_: { 'Highest Rank' => 'Name',
      #           ...
      #           'Lowest Rank' => 'Name' }
      def search_tree(hash)
        hash.reduce(nil) do |geo, (rank, name)|
          geo_names = geo&.children_dataset || names_dataset
          geo = geo_names.where(Name: name, administrative_division: rank(rank))
          next geo.first unless geo.count > 1
          raise AMBIGUOUS_MATCH_ERROR +
                " for #{name}: #{geo.to_a.map(&:FullName)}"
        end
      end
    end
  end
end
