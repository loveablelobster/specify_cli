# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonEquivalents are finder objects that wrap TaxonResponeses and find
    # their equivalent in the Specify database
    # TODO: should have bools for exists in DB
    class TaxonEquivalent
      # The id for the taxon record used by the web service.
      attr_reader :concept

      attr_accessor :missing_ancestors # FIXME: moved to TaxonLineage

      attr_reader :name

      attr_reader :rank

      # The URI of the web service used.
      # e.g. http://webservice.catalogueoflife.org/col/webservice
      attr_reader :service_url

      attr_reader :taxon

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
        @parent = nil # TODO: should be false if not persisted, taxoneq else
        @rank = concept.rank
        @taxon = nil
        @referenced = false
      end

      # Returns an Array of TaxonEquivalent instances for all ancestors in the
      # TaxonResponse's classification.
      def ancestors
        # FIXME: fill a TaxonLineage instead
        concept.classification
               .map { |t| TaxonEquivalent.new(taxonomy, t) }
               .sort_by(&:rank)
      end

      # Returns the ID of the taxon concept in the external resource
      # (CatalogueOfLife)
      def concept_id
        concept.id
      end

      def create(fill_lineage: false)
        if parent?
          @taxon = known_ancestor.taxon.add_child to_model_attributes
        elsif fill_lineage
          # fille the lineage
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

      # Finds a taxon by the #service_url and +id+ attribute of #concept
      # (the Catalogue Of Life id).
      def find_by_id
        @taxon = taxonomy.names_dataset.first(Source: service_url,
                                              TaxonomicSerialNumber: concept.id)
        @referenced = true if @taxon
        @taxon
      end

      # Finds the taxon for +self+ in #taxonomy by _name_, _rank_, and
      # optionally _parent_, if a TaxonEquivalent as passed in as the +parent+
      # argument.
      def find_by_values(parent = nil)
        vals = { Name: concept.name,
                 rank: concept.rank.equivalent(taxonomy),
                 parent: parent&.find }
        results = taxonomy.names_dataset.where(vals.compact)
        return results if results.count > 1

        @taxon = results.first
      end

      # Returns the closest ancestor known in #taxonomy.
      # Can be referenced if desired
      # Access Model::Taxon through TaxonEquivalent#taxon
      # If TaxonResponse#root? for the TaxonResponse stored in #concept is
      # +true+ this will also return +false+.
      def known_ancestor
        # FIXME: delegate the parent finding to TaxonLineage
        @parent = ancestors.find.with_index do |ancestor, i|
          match = ancestor.find(ancestors[i + 1])
          missing_ancestors << ancestor unless match
          match
        end
        @parent ||= false
      end

      # Returns +true+ if the immediate ancestor is known in the databse.
      def parent?
        ancestor = known_ancestor
        return ancestor if ancestor && missing_ancestors.empty?
      end

      # Updates _@taxon_ (Specify::Model::Taxon), sets +TaxonomicSerialNumber+
      # to tge concept id.
      def reference!
        return if referenced?

        return unless @taxon

        @taxon.TaxonomicSerialNumber = concept_id
        @taxon.Source = service_url
        @taxon.save
        @referenced = true
      end

      # Returns true if the concept is referenced in the database by id
      # (+TaxonomicSerialNumber+).
      # Returns +nil+ if #find has nor been  called
      def referenced?
        return unless @taxon

        @referenced
      end

      # Returns a hash, mapping #concept attributes to Specify::Model::Taxon
      # attributes
      def to_model_attributes
        {
          Author: concept.author,
          COLStatus: concept.name_status,
          IsAccepted: concept.accepted?, # TODO: should insert valid taxon
          IsHybrid: false, # CatalogueOfLife does not yield hybrid information
          Name: concept.name,
          rank: rank.equivalent(taxonomy),
          RankID: rank.equivalent(taxonomy).RankID,
          Source: service_url,
          TaxonomicSerialNumber: concept_id
        }
      end
    end
  end
end
