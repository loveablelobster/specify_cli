# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # A TaxonEquivalents is a logical link between identical taxonbomic concepts
    # as they exist in an internal resource (the taxonomy of a databade) and an
    # external resource (a taxon authority web service). As such, it will have
    # a pair of corresponding concepts, and #iternal ( Specify::Model::Taxon),
    # and and #external (a Specify::CatalogueOfLife:;TaxonResponse).
    # TaxonEquivalents can act as finder objects, where, if initialized with one
    # of the corresponding concepts, they can find the other).
    class TaxonEquivalent
      # The external representation of the concept, i.e. the taxon in the
      # authotiy service (a Specify::CatalogueOfLife::TaxonResponse).
      attr_reader :external

      # Returns a String with the name of the taxon (common to both the
      # extarnal and internal).
      attr_reader :name

      # Returns the rank for either the external or internal representation
      # of the concept. This will be a Specify::CatalogueOfLife::Rank for
      # the external representation, a Specify::Model::Rank for the internal
      # representation.
      attr_reader :rank

      # The internal representation of the comcept, i.e. the taxon in the
      # database (a Specify::Model::Taxon)
      attr_reader :internal

      # The Specify::Model::Taxonomy.
      attr_reader :taxonomy

      # Returns a new instance.
      # +taxonomy+ is a Specify::Model::Taxonomy
      # +response+ is a Specify::CatalogueOfLife::TaxonResponse
      def initialize(taxonomy, internal: nil, external: nil)
        @taxonomy = taxonomy
        @external = external
        @internal = internal
        @name = internal&.name || external&.name
        @rank = internal&.rank || external&.rank
        @lineage = nil
        @referenced = false
      end

      def ancestors
        lineage.ancestors
      end

      # Returns an OpenStruct with the IDs for the external (the
      # CatalogueOfLife ID) and internal (the database taxonomy) representations
      # of the taxon concept.
      def id
        OpenStruct.new(internal: internal&.id, external: external&.id)
      end

      # If _parent_ is passes, will create in the parent
      def create(parent = nil, fill_lineage: false)
        parent ||= parent_taxon
        if parent
          @internal = parent.internal.add_child to_model_attributes
        elsif fill_lineage
          # fill the lineage
        else
          # TODO: consolidate into error constants
          raise 'Immidiate ancestor missing'
        end

        # taxonomy.add_name(vals)
      end

      # Finds a taxon in #taxonomy.
      def find(parent = nil)
        find_by_id || find_by_values(parent)
      end

      # Finds a taxon by the service_url (URL + API_ROUTE) and +id+ attribute
      # of #external
      # (the Catalogue Of Life id).
      def find_by_id
        @internal = taxonomy.names_dataset
                            .first(Source: URL + API_ROUTE,
                                   TaxonomicSerialNumber: external.id)
        @referenced = true if @internal
        @internal
      end

      # Finds the taxon for +self+ in #taxonomy by _name_, _rank_, and
      # optionally _parent_, if a TaxonEquivalent as passed in as the +parent+
      # argument.
      def find_by_values(parent = nil)
        vals = { Name: external.name,
                 rank: external.rank.equivalent(taxonomy),
                 parent: parent&.find }
        results = taxonomy.names_dataset.where(vals.compact)
        return results if results.count > 1

        @internal = results.first
      end

      # Returns the closest ancestor known in #taxonomy.
      # Can be referenced if desired
      # Access Model::Taxon through TaxonEquivalent#taxon
      # If Taxon#root? for the CatalogueOfLife::Taxon stored in #external is
      # +true+ this will also return +false+.
      def known_ancestor
        lineage.known_ancestor
      end

      def lineage
        @lineage || parse_lineage
      end

      def missing_ancestors
        lineage.missing_ancestors
      end

      # Returns the TaxonEquivalent for the immediate ancestor if it is known
      # in the database, otherwise returns +false+.
      def parent_taxon
        lineage.missing_ancestors.empty? ? lineage.known_ancestor : false
      end

      # Updates _@taxon_ (Specify::Model::Taxon), sets +TaxonomicSerialNumber+
      # to tge external id.
      def reference!
        return if referenced?

        return unless @internal

        @internal.TaxonomicSerialNumber = external.id
        @internal.Source = URL + API_ROUTE
        @internal.save
        @referenced = true
      end

      # Returns true if #external is referenced in the database by id
      # (+TaxonomicSerialNumber+).
      # Returns +nil+ if #find has nor been  called
      def referenced?
        return unless @internal

        @referenced
      end

      # Returns a hash, mapping #external attributes to Specify::Model::Taxon
      # attributes
      def to_model_attributes
        {
          Author: external.author,
          COLStatus: external.name_status,
          IsAccepted: external.accepted?, # TODO: should insert valid taxon
          IsHybrid: false, # CatalogueOfLife does not yield hybrid information
          Name: external.name,
          rank: rank.equivalent(taxonomy),
          RankID: rank.equivalent(taxonomy).RankID,
          Source: URL + API_ROUTE,
          TaxonomicSerialNumber: external.id
        }
      end

      private

      # Returns an Array of TaxonEquivalent instances for all ancestors in the
      # Taxon instances classification.
      def parse_lineage
        @lineage = TaxonLineage.new(external.classification, taxonomy)
      end
    end
  end
end
