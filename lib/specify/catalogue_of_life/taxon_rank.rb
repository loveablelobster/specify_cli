# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # + sub/super
    RANKS = %i[infraspecies species genus
               family order class phylum kingdom].freeze
    PREFIXES = [:sub, nil, :super].freeze

    # TaxonRanks represent taxonomic ranks.
    class TaxonRank
      include Comparable

      # The full name of the rank.
      attr_reader :name

      # The stem of the #name.
      attr_reader :stem

      # The prefix of the #name (+super+ or +sub+)
      # or super = 1, nil = 0, sub = -1
      attr_reader :prefix

      def initialize(str)
        /^(?<prefix>super|sub)?(?<stem>\w+)$/.match(str.downcase) do |m|
          @name = m[0].to_sym
          @stem = m[:stem].to_sym
          @prefix = m[:prefix]&.to_sym
        end
        raise "Invalid taxon rank #{name}" unless valid?
      end

      def self.stem
        RANKS
      end

      def self.prefix
        PREFIXES
      end

      def <=>(other)
        if name == other.name
          0
        elsif stem == other.stem
          position(:prefix) <=> other.position(:prefix)
        else
          position <=> other.position
        end
      end

      def equivalent(taxonomy)
        taxonomy.ranks_dataset.first(Name: to_s)
      end

      # Returns the index of #stem or #prefix in RANKS and PREFIXES
      # respectively.
      def position(attr = :stem)
        TaxonRank.public_send(attr).index public_send(attr)
      end

      def to_s
        return 'subspecies' if name == :infraspecies # FIXME

        name.to_s
      end

      # Returns true if the rank is present in RANKS and PREFIXES.
      def valid?
        RANKS.include?(stem) && PREFIXES.include?(prefix)
      end
    end
  end
end
