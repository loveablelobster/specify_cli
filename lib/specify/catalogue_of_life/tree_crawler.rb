# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    class TreeCrawler
      # A TaxonResponse
      attr_reader :root

      # A TaxonRank that is the last taxonomic level that will be crawled.
      attr_reader :stop_rank

      def initialize(root = { id: nil, root_name: nil, root_rank: nil })
        request = if root[:id]
                    TaxonRequest.by_id root[:id]
                  else
                    TaxonRequest.new do |req|
                      req.name = root[:name]
                      req.rank = root[:rank]
                    end
                  end
        @root = request.response
        @stop_rank = nil
        yield(self) if block_given?
      end

      # TODO: options
      # TODO: parent should be able to accept a TaxonEquivalent
      def crawl(parent = nil,
                options = { crawl_synonyms: false, include_extinct: false },
                &block)
        parent ||= root
        return unless parent.children?
        children = parent.children.map do |child|
          Thread.new(child) { |id| TaxonRequest.by_id(id).response }
        end
        children.each do |child|
          child.value.parent = parent
          yield(child.value) # FIXME: move up to parent before return again?
          crawl(child.value, options, &block)
        end
      end

      def stop_rank=(name)
        @stop_rank = TaxonRank.new name
      end
    end
  end
end
