# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonEquivalents are finder objects that wrap TaxonResponeses and find
    # their equivalent in the Specify database
    # TODO: should have bools for exists in DB
    class TaxonEquivalent
      # The id for the taxon record used by the web service.
      attr_reader :concept

      attr_accessor :missing_ancestors

      attr_reader :name

      attr_reader :rank

      # The URI of the web service used.
      # e.g. http://webservice.catalogueoflife.org/col/webservice
      attr_reader :service_url

      # The Specify::Model::Taxonomy.
      attr_reader :taxonomy

      # Returns a new instance.
      # +taxonomy+ is a Specify::Model::Taxonomy
      # +response+ is a Specify::CatalogueOfLife::TaxonResponse
      def initialize(taxonomy, response = nil)
        @concept = response
        @service_url = CatalogueOfLife::URL
        @taxonomy = taxonomy
        @missing_ancestors = []
        @name = concept.name
        @rank = concept.rank
      end

      # Returns an Array of TaxonEquivalent instances for all ancestors in the
      # TaxonResponse's classification.
      def ancestors
        concept.classification
               .map { |t| TaxonEquivalent.new(taxonomy, t) }
               .sort_by(&:rank)
      end

      # Returns the ID of the taxon concept in the external resource
      # (CatalogueOfLife)
      def concept_id
        concept.id
      end

      def create(vals)
        vals[:Source] = service_url
        vals[:TaxonomicSerialNumber] = id
        # TODO: find the parent
        taxonomy.add_name(vals)
      end

      # Finds a taxon in #taxonomy.
      def find(parent = nil)
        find_by_id || find_by_values(parent)
      end

      # Finds a taxon by the #service_url and +id+ attribute of #concept
      # (the Catalogue Of Life id).
      def find_by_id
        taxonomy.names_dataset.first(Source: service_url,
                                     TaxonomicSerialNumber: concept.id)
      end

      # Finds the taxon for +self+ in #taxonomy by _name_, _rank_, and
      # optionally _parent_, if a TaxonEquivalent as passed in as the +parent+
      # argument.
      def find_by_values(parent = nil)
        vals = { Name: concept.name,
                 rank: concept.rank.equivalent(taxonomy),
                 parent: parent&.find }
        results = taxonomy.names_dataset.where(vals.compact)
        results.count > 1 ? results : results.first
      end

      # Returns the closest ancestor known in #taxonomy.
      def known_ancestor
        lineage = ancestors
        lineage.each_with_index do |ancestor, i|
          match = ancestor.find(lineage[i + 1])
          return match if match

          missing_ancestors << ancestor
        end
      end
    end
  end
end
