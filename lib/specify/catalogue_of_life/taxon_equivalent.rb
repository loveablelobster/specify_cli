# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonEquivalents are finder objects that wrap TaxonResponeses and find
    # their equivalent in the Specify database
    # TODO: should have bools for exists in DB
    class TaxonEquivalent
      # The id for the taxon record used by the web service.
      attr_reader :concept

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
        @name = concept.name
        @rank = concept.rank
#         @taxon = find
      end

      # Returns an Array of TaxonEquivalent instances for all ancestors in the
      # TaxonResponse's classification.
      def ancestors
        concept.classification
               .map { |t| TaxonEquivalent.new(taxonomy, t) }
               .sort { |a, b| a.rank <=> b.rank }
      end

      # Returns the ID of the taxon concept in the external resource
      # (CatalogueOfLife)
      def concept_id
        concept.id
      end

      # Returns a Hash with values to find the concept in the taxonomy
      def concept_query_values
        { Name: concept.name,
          rank: concept.rank.equivalent(taxonomy) }
      end

      def create(vals)
        vals[:Source] = service_url
        vals[:TaxonomicSerialNumber] = id
        # TODO: find the parent
        taxonomy.add_name(vals)
      end

      def find
        find_by_id || find_by_values
      end

      def find_by_id
        taxonomy.names_dataset.first(Source: service_url,
                                     TaxonomicSerialNumber: concept.id)
      end

      def find_by_values
        # TODO: should also include parent
        p find_parent
        results = taxonomy.names_dataset.where(concept_query_values)
        return results.first if results.count == 1
        raise 'Multiple matches' if results.count > 1
      end

      # Returns the Specify::Model::Taxon for the immediate ancestor of +self+.
      # Will return nil if not found
      # FIXME: should throw symbol :root if there are no ancestors
      def find_parent
        return unless ancestors.first
        ancestors.first.find
      end

      # Returns an Array of TaxonEquivalent instances for all ancestors that
      # exist in #taxomy
      def known_ancestors(method = :find)
        ancestors.select { |anc| anc.public_send(method) }
      end

      # Returns an Array of TaxonEquivalent instances for all ancestors that
      # do not exist in #taxomy
      def missing_ancestors(method = :find)
        ancestors.reject { |anc| anc.public_send(method) }
      end

      # Returns a TaxonEquivalent instance for the parent of +self+
      def parent_equivalent
        TaxonEquivalent.new(taxonomy, concept.parent)
      end
    end
  end
end
