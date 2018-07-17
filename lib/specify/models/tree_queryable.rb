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
        hash.reduce(nil) do |item, (rank_name, name)|
          searchset = item&.children_dataset || names_dataset
          item = searchset.where(Name: name,
                                 rank: rank(rank_name))
          next item.first unless item.count > 1
          raise AMBIGUOUS_MATCH_ERROR +
                " for #{name}: #{item.to_a.map(&:FullName)}"
        end
      end
    end
  end
end
