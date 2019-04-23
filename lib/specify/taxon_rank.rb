# frozen_string_literal: true

module Specify
  # An ordered array of symbols for available rank stems.
  RANKS = %i[infraspecies species genus
             family order class phylum kingdom].freeze

  # An ordered array of symbols and +nil+ for available rank prefixes, where
  # +nil+ corresponds to no prefix.
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

    # Returns a new instance from a String (+str+) with the name for the
    # taxonomic rank (e.g. 'Species', 'Genus', 'Subfamily', etc.)
    def initialize(str)
      /^(?<prefix>super|sub)?(?<stem>\w+)$/.match(str.downcase) do |m|
        @name = m[0].to_sym
        @stem = m[:stem].to_sym
        @prefix = m[:prefix]&.to_sym
      end
      raise RankError::INVALID_RANK + ' ' + name unless valid?
    end

    # Returns a list of symbols for all available ranks.
    def self.available_ranks
      spp = RANKS[0..1]
      suprasp = RANKS[2..-1].map do |r|
        PREFIXES.map do |px|
          next if r == :genus && px == :super

          px ? (px.to_s + r.to_s).to_sym : r
        end
      end
      spp + suprasp.flatten.compact
    end

    # Returns a new instance for any symbol in #available_ranks.
    def self.method_missing(method, *args, &block)
      super unless TaxonRank.respond_to_missing?(method)

      TaxonRank.new method
    end

    # Returns an ordered array of symbols and +nil+ for available rank
    # prefixes, where +nil+ correspons to no prefix. This class method is
    # required by the instance method #position, which uses the array to
    # resolve the relative order of a prefixed rank.
    def self.prefix
      PREFIXES
    end

    # Returns an ordered array of symbols for available rank stems. This
    # class method is required by the instance method #position, which uses
    # the array to resolve the relative order of a rank.
    def self.stem
      RANKS
    end

    # Returns true for any symbol in #available_ranks.
    def self.respond_to_missing?(method_name, include_private = false)
      available_ranks.include?(method_name) || super
    end

    # Compares +self+ to another instance based on the relatibe position of a
    # rank (Kingdom > Phylum > Class > Order > Family > Genus > Species >
    # Infraspecies). Considers ranks wirh modifiers (i.e. prefixes;
    # Superfamily > Family > Subfamily).
    def <=>(other)
      if name == other.name
        0
      elsif stem == other.stem
        position(:prefix) <=> other.position(:prefix)
      else
        position <=> other.position
      end
    end

    # Returns the Specify::Model::Rank instance that represents +self+ in
    # _taxonomy_ (an instance of Specify::Model::Taxonomy).
    def equivalent(taxonomy)
      taxonomy.ranks_dataset.first(Name: to_s)
    end

    # Returns the index (an Integer) of #stem or #prefix in RANKS and PREFIXES
    # respectively.
    def position(attr = :stem)
      TaxonRank.public_send(attr).index public_send(attr)
    end

    # Returns a capitalized String for the #name of self. Will substitute
    # +Subspecies+ for +Infraspecies+.
    def to_s
      return 'Subspecies' if name == :infraspecies # FIXME

      name.to_s.capitalize
    end

    private

    # Returns true if the rank is present in RANKS and PREFIXES.
    def valid?
      RANKS.include?(stem) && PREFIXES.include?(prefix)
    end
  end
end
