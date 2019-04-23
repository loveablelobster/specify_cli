# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonEquivalents are finder objects that wrap TaxonResponeses and find
    # their equivalent in the Specify database
    # TODO: should have bools for exists in DB
    class TaxonEquivalent
      # The id for the taxon record used by the web service.
      attr_reader :service_taxon

      attr_reader :name

      attr_reader :rank

      attr_reader :specify_taxon

      # The Specify::Model::Taxonomy.
      attr_reader :taxonomy

      # Returns a new instance.
      # +taxonomy+ is a Specify::Model::Taxonomy
      # +response+ is a Specify::CatalogueOfLife::TaxonResponse
      def initialize(taxonomy, response = nil)
        @service_taxon = response
        @taxonomy = taxonomy
        @name = service_taxon.name
        @lineage = nil
        @rank = service_taxon.rank
        @specify_taxon = nil
        @referenced = false
      end

      def ancestors
        lineage.ancestors
      end

      # Returns the ID of the taxon concept in the external resource
      # (CatalogueOfLife)
      def concept_id
        service_taxon.id
      end

      # If _parent_ is passes, will create in the parent
      def create(parent = nil, fill_lineage: false)
        parent ||= parent_taxon
        if parent
          @specify_taxon = parent.specify_taxon.add_child to_model_attributes
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
      # of #service_taxon
      # (the Catalogue Of Life id).
      def find_by_id
        @specify_taxon = taxonomy.names_dataset
                                 .first(Source: URL + API_ROUTE,
                                        TaxonomicSerialNumber: service_taxon.id)
        @referenced = true if @specify_taxon
        @specify_taxon
      end

      # Finds the taxon for +self+ in #taxonomy by _name_, _rank_, and
      # optionally _parent_, if a TaxonEquivalent as passed in as the +parent+
      # argument.
      def find_by_values(parent = nil)
        vals = { Name: service_taxon.name,
                 rank: service_taxon.rank.equivalent(taxonomy),
                 parent: parent&.find }
        results = taxonomy.names_dataset.where(vals.compact)
        return results if results.count > 1

        @specify_taxon = results.first
      end

      # Returns the closest ancestor known in #taxonomy.
      # Can be referenced if desired
      # Access Model::Taxon through TaxonEquivalent#taxon
      # If TaxonResponse#root? for the TaxonResponse stored in #service_taxon is
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
      # to tge service_taxon id.
      def reference!
        return if referenced?

        return unless @specify_taxon

        @specify_taxon.TaxonomicSerialNumber = concept_id
        @specify_taxon.Source = URL + API_ROUTE
        @specify_taxon.save
        @referenced = true
      end

      # Returns true if #service_taxon is referenced in the database by id
      # (+TaxonomicSerialNumber+).
      # Returns +nil+ if #find has nor been  called
      def referenced?
        return unless @specify_taxon

        @referenced
      end

      # Returns a hash, mapping #service_taxon attributes to Specify::Model::Taxon
      # attributes
      def to_model_attributes
        {
          Author: service_taxon.author,
          COLStatus: service_taxon.name_status,
          IsAccepted: service_taxon.accepted?, # TODO: should insert valid taxon
          IsHybrid: false, # CatalogueOfLife does not yield hybrid information
          Name: service_taxon.name,
          rank: rank.equivalent(taxonomy),
          RankID: rank.equivalent(taxonomy).RankID,
          Source: URL + API_ROUTE,
          TaxonomicSerialNumber: concept_id
        }
      end

      private

      # Returns an Array of TaxonEquivalent instances for all ancestors in the
      # TaxonResponse's classification.
      def parse_lineage
        @lineage = TaxonLineage.new(service_taxon.classification, taxonomy)
      end
    end
  end
end
