# frozen_string_literal: true

module Specify
  module Model
    # TreeQueryable is a mixin that provides methods to query _trees_
    # such as Specify::Model::Taxnoomy and Specify::Model::Geography.
    #
    # Trees are nested hierarchies that are represented by three classes
    # - an _item_ class, holding information about the items to be classified in
    # a _tree_, such as taxonomic or geographic names.
    # - a _rank_ class, which designates items as belonging to a formal rank or
    # level within the tree
    # - the _tree_ class itself, which identifies all items and ranks belonging
    # to one tree.
    #
    # For taxonomies, the _tree_ class is Specify::Model::Taxonomy,
    # the _item_ class is Specify::Model::Taxon, the _rank_ class is
    # Specify::Model::Rank.
    #
    # For geographies, the _tree_ class is Specify::Model::Geography, the
    # _item_ class is Specify::Model::GeographicName, the _rank_ class is
    # Specify::Model::AdministrativeDivision.
    module TreeQueryable
      AMBIGUOUS_MATCH_ERROR = 'Ambiguous results during tree search'

      # Returns the _rank_ instance in a tree for +rank_name+ (a String).
      #
      # _rank_ classes are Specify::Model::AdministrativeDivision (for
      # Specify::Model::Geography), and Specify::Model::Rank (for
      # Specify::Model::Taxonomy).
      def rank(rank_name)
        ranks_dataset.first(Name: rank_name.capitalize)
      end

      # Preforms a tree search, traversing a hierarchy from highest to lowest
      # _rank_. +hash+ is a Hash with the structure
      # <tt>{ 'rank' => 'name' }</tt> where +rank+ is an existing _rank_ name,
      # +name+ an existing _item_ name with that rank. Give key value paris in
      # descencing order of rank:
      #   { 'rank 1' => 'name',
      #     'rank 2' => 'name'
      #     'rank n' => 'name' }
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
