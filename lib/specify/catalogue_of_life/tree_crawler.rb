# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    class TreeCrawler
      # A CatalogueOfLife::Taxon
      attr_reader :root

      # CatalogueOfLife::Rank that is the last taxonomic level that will be
      # crawled.
      attr_reader :stop_rank

      def initialize(root = nil, **opts)
        @root = root
        @stop_rank = nil
        yield(self) if block_given?
        @root.find || @root.create(opts)
      end

      # TODO: options :skip_subgenera
      # TODO: :crawl_synonyms may be handled in Equivalent ?
      def crawl(parent = nil,
                options = { crawl_synonyms: false, include_extinct: false },
                &block)
        parent ||= root
        parent.taxon.children.each do |child|
          child_equivalent = Equivalent.new parent.taxonomy, child
          yield(child_equivalent)
          crawl(child_equivalent, options, &block)
        end
      end

      def stop_rank=(name)
        @stop_rank = Rank.new name
      end
    end
  end
end
