# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    GENUS = Rank.new(:genus)

    # A Taxon wraps a Faraday::Response to provide an interface for
    # work with the Equivalent class.
    # The repsonses of the CatalogueOfLife of life service have different
    # sets of properties for valid names, synonyms, and suprageneric taxa.
    # Available properties in suprageneric taxa are:
    # * :id
    # * :name
    # * :rank
    # * :name_status
    # * :name_html
    # * :url
    # * :is_extinct
    # * :classification
    # * :child_taxa
    #
    # Synonym have the above except :is_extinct, :classification, :child_taxa,
    # and add:
    # * :genus
    # * :subgenus
    # * :species
    # * :infraspecies_marker
    # * :infraspecies
    # * :author
    # * :record_scrutiny_date
    # * :online_resource
    # * :source_database
    # * :source_database_url
    # * :bibliographic_citation
    # * :accepted_name
    #
    # Valid names have the shared properties of suprageneric taxa and synonyms,
    # and except :accepted_name, and add:
    # * :distribution
    # * :references
    # * :common_names
    # * :synonyms
    class Taxon
      # Returns the full response body (Hash).
      attr_reader :full_response

      # Returns the CatalogueOfLife::Rank for +self+.
      attr_reader :rank

      # Returns a new instance. +col_result_hash+ is a hash from the array of
      # _results_ in the response body from an HTTP request to the
      # CatalogueOfLife service.
      def initialize(col_result_hash)
        @full_response = col_result_hash
        @rank = Rank.new col_result_hash['rank']
      end

      # Returns +true+ if the name is a valid taxonomic name according to
      # CatalogueOfLife.
      def accepted?
        full_response['name_status'] == 'accepted name'
      end

      # Returns a CatalogueOfLife::Taxon for the accepted name if +self+ is a
      # synonym (not accepted).
      def accepted_name
        accepted_id = full_response['accepted_name']&.fetch('id', nil)
        return unless accepted_id

        Request.by_id(accepted_id).taxon
      end

      # Returns the author name for the taxon according to CatalogueOfLife.
      def author
        full_response['author']
      end

      # Returns an Array of CatalogueOfLife::Taxon instances for all direct
      # child taxa of +self+. Returns an empty Array if there are no direct
      # child taxa.
      def children
        return [] unless children?

        fetch 'child_taxa'
      end

      # Returns +true+ if +self+ has direct child taxa according to
      # CatalogueOfLife, +false+ otherwise. Note that CatalogueOfLife of life
      # responses for synonyms (where #accepted? is +false+) do not list
      # child taxa.
      def children?
        full_response['child_taxa'] && !full_response['child_taxa'].empty?
      end

      # Returns an orderd Array of CatalogueOfLife::Taxon instances for each
      # taxon in the ancestor chain (lineage) of self, starting with the highest
      # rank (root of the CatalogueOfLife taxonomy; usually the kingdom). The
      # immediate ancestor/parent taxon of +self+ will be the last element of
      # the array.
      # There is currently a bug in CatalogueOfLife where subgenera are listed
      # in classifications but not searchable. The option <em>skip_subgenera<em>
      # (+true+ by default) allows to skip subgenera in the classification.
      def classification(skip_subgenera: true)
        responses = full_response['classification']&.map do |anc|
          next if skip_subgenera && anc['rank'].casecmp('subgenus').zero?

          if anc['rank'].casecmp('subgenus').zero? && !skip_subgenera
            raise ResponseError::SERVICE_RELIABILITY
          end

          Thread.new(anc) { Request.by_id(anc['id']).taxon }
        end
        responses.compact.map(&:value)
      end

      # Returns an Array of Hashes with common names for the txaon. Each hash
      # will have the keys +:name+, +:language+, +:country+, +:references+,
      # where references will hold an array of hashes, each with the keys:
      # +:author+, +:year+, +:title+, +source+.
      def common_names
        full_response.fetch('common_names', []).map do |entry|
          entry['references'] = entry['references']
            .map { |ref| ref.transform_keys(&:to_sym) }
          entry.transform_keys(&:to_sym)
        end
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

      # Returns the taxonomic name for +self+, but only the part of the name
      # designating the taxon, i.e. it will return the epithet only for ranks
      # lower than _Genus_ (_Subgenus_, _Species_, any infraspecific taxon)
      # rather than the binomen.
      def name
        if rank < GENUS
          infraspecies || species || subgenus
        else
          full_response['name']
        end
      end

      # Returns a CatalogueOfLife::Taxon for the direct parent taxon of +self+.
      # There is currently a bug in CatalogueOfLife where subgenera are listed
      # in classifications but not searchable. The option <em>skip_subgenera<em>
      # (+true+ by default) allows to skip subgenera in the classification.
      def parent(skip_subgenera: true)
        direct_ancestor = full_response['classification'].last
        return unless direct_ancestor

        if skip_subgenera && direct_ancestor['rank'].casecmp('subgenus').zero?
          direct_ancestor = full_response['classification'][-2]
        elsif !skip_subgenera && direct_ancestor['rank'].casecmp('subgenus')
                                                        .zero?
          raise ResponseError::SERVICE_RELIABILITY

        end

        parent_id = direct_ancestor.fetch('id')

        Request.by_id(parent_id).taxon
      end

      # Returns true if +self+ is the root of the CatalogueOfLife classification
      # (typically where #rank is +kingdom+), +false+ if there are parent taxa
      # in the classification. Will return +nil+ if the response has no
      # classification.
      def root?
        return unless full_response['classification']

        full_response['classification'].empty?
      end

      # Returns an array of CatalogueOfLife::Taxon instances for synonyms listed in the
      # full response of +self+ (given that +self+ is an accepted name).
      def synonyms
        return [] unless synonyms?

        fetch 'synonyms'
      end

      # Returms +true+ if +self+ has synonyms (given that +self+ is an accepted
      # name).
      def synonyms?
        return unless full_response.key? 'synonyms'

        !full_response['synonyms'].empty?
      end

      # Returns a String representation of +self+.
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

      private

      def fetch(key)
        responses = full_response[key].map do |req|
          Thread.new(req) { Request.by_id(req['id']).taxon }
        end
        responses.map(&:value)
      end
    end
  end
end
