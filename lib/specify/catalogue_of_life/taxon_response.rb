# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    GENUS = TaxonRank.new(:genus)

    # A TaxonRepsonse wraps a Faraday::Response to provide an interface for
    # work with the TaxonEquivalent class.
    class TaxonResponse
      # Returns the full response body (Hash).
      attr_reader :full_response

      # Returns the TaxonRank for +self+.
      attr_reader :rank

      def initialize(col_result_hash)
        @full_response = col_result_hash
        @rank = TaxonRank.new col_result_hash['rank']
      end

      def accepted?
        full_response['name_status'] == 'accepted name'
      end

      def author
        full_response['author']
      end

      def children
        return [] unless children?

        full_response['child_taxa'].map { |child| child['id'] }
      end

      def children?
        full_response['child_taxa'] && !full_response['child_taxa'].empty?
      end

      def classification
        responses = full_response['classification']&.map do |anc|
          Thread.new(anc) { TaxonRequest.by_id(anc['id']).response }
        end
        responses.map(&:value)
      end

      # TODO: add Source: 'CatalogueOfLife' to criteria
      # TODO: remove, should be handled by TaxonEquivalent
      def equivalent(taxonomy)
        taxonomy.names_dataset.first(TaxonomicSerialNumber: id) ||
          taxonomy.names_dataset.first(Name: name,
                                       rank: rank.equivalent(taxonomy))
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

      # FIXME: necessary?
      def parent
        parent_id = full_response['classification'].last&.fetch('id')
        return unless parent_id

        TaxonRequest.by_id(parent_id).response
      end

      def root?
        return unless full_response['classification']

        full_response['classification'].empty?
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
