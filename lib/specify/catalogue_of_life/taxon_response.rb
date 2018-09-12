# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    GENUS = TaxonRank.new(:genus)

    #
    class TaxonResponse
      #
      attr_reader :full_response

      #
      attr_accessor :parent

      #
      attr_reader :rank

      def initialize(col_result_hash)
        @full_response = col_result_hash
        @parent = @full_response['classification'].last
        @rank = TaxonRank.new col_result_hash['rank']
      end

      def accepted?
        full_response['name_status'] == 'accepted name'
      end

      def children
        return [] unless children?

        full_response['child_taxa'].map { |child| child['id'] }
      end

      def children?
        full_response['child_taxa'] && !full_response['child_taxa'].empty?
      end

      def equivalent(taxonomy)
        taxonomy.names_dataset.first Name: name,
                                     rank: rank.equivalent(taxonomy)
      end

      # Returns +true+ if +self+ is extinct, +false+ otherwise.
      # Catalogue of Life taxon response will use `'true'` or `'false'` for
      # the extinct status of valid names, `0` or `1` in the nested `synonyms`
      # attribute. Synonyms will not have extinct status in the root level
      #  nesting of the response results.
      def extinct?
        return unless full_response.key? 'is_extinct'

        ['true', 1].include? full_response['is_extinct']
      end

      def name
        if rank < GENUS
          infraspecies || species || subgenus
        else
          full_response['name']
        end
      end

      def synonyms
        return [] unless synonyms?

        full_response['synonyms'].map { |synonym| synonym['id'] }
      end

      def synonyms?
        return unless full_response.key? 'synonyms'

        !full_response['synonyms'].empty?
      end

      def to_s
        "#{name} (#{rank}), has children: #{children?},"\
        " accepted: #{accepted?}, extinct: #{extinct?}"
      end

      def method_missing(method_name, *args, &block)
        val = full_response.fetch(method_name.to_s) do
          # if rank < GENUS available keys will be different
          super
        end
        val&.empty? ? nil : val
      end

      def respond_to_missing?(method_name, include_private = false)
        full_response.key?(method_name.to_s) || super
      end
    end
  end
end

# Keys in suprageneric taxa
# :id
# :name
# :rank
# :name_status
# :name_html
# :url
# :is_extinct
# :classification
# :child_taxa
