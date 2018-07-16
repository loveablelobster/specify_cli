# frozen_string_literal: true

module Specify
  module Model
    # Mixin that provides convienience methods for nested hierarchies.
    module TreeQueryable
      # ->
      def rank(rank_name)
        ranks_dataset.first(Name: rank_name.capitalize)
      end

      # ->
      # _hash_: { 'Highest Rank' => 'Name',
      #           ...
      #           'Lowest Rank' => 'Name' }
      # FIXME: This should be allowed to skip ranks that are not enforced
      def search_tree(hash)
        hash.reduce(nil) do |geo, (rank, name)|
          geo_names = geo&.children_dataset || names_dataset
          div = rank(rank)
          geo = geo_names.first(Name: name, administrative_division: div)
        end
      end
    end
  end
end
