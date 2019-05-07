# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # A Equivalents is a logical link between identical taxonbomic concepts
    # betweern two resources (a database taxonomy and an external authority
    # service).
    # It will be initialized with a Taxon (Model::Taxon or
    # CatalogueOfLife::Taxon), that will form the #taxon attribute, and will
    # look for an #equivalent in the respective other resource.
    # Equivalents can act as finder objects, where, if initialized with one
    # of the corresponding concepts, they can find the other).
    class Equivalent
      # Returns a String with the name of the taxon (common to both the
      # extarnal and internal).
      attr_reader :name

      # Returns the rank for either the external or internal representation
      # of the concept. This will be a Specify::CatalogueOfLife::Rank for
      # the external representation, a Specify::Model::Rank for the internal
      # representation.
      attr_reader :rank

      attr_reader :taxon

      attr_reader :equivalent

      # The Specify::Model::Taxonomy.
      attr_reader :taxonomy

      # Returns a new instance.
      # +taxonomy+ is a Specify::Model::Taxonomy
      # +response+ is a Specify::CatalogueOfLife::TaxonResponse
      def initialize(taxonomy, taxon)
        @taxonomy = taxonomy
        @taxon = taxon
        @equivalent = nil
        @name = taxon.name
        @rank = taxon.rank
        @lineage = nil
        @referenced = false
      end

      def ancestors
        lineage.ancestors
      end

      def external; end
      def internal; end

      # Returns an OpenStruct with the IDs for the #taxon +self+ has been
      # initialized with and the #equivalent.
      def id
        OpenStruct.new(taxon: taxon.id, equivalent: equivalent&.id)
      end

      # If _parent_ is passed, will create in the parent
      def create(parent = nil, fill_lineage: false)
        parent ||= parent_taxon
        if parent
          @equivalent = parent.equivalent.add_child to_model_attributes
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
      # of #taxon
      # (the Catalogue Of Life id).
      def find_by_id
        @equivalent = taxonomy.names_dataset
                            .first(Source: URL + API_ROUTE,
                                   TaxonomicSerialNumber: taxon.id)
        @referenced = true if @equivalent
        @equivalent
      end

      # Finds the taxon for +self+ in #taxonomy by _name_, _rank_, and
      # optionally _parent_, if a Equivalent as passed in as the +parent+
      # argument.
      def find_by_values(parent = nil)
        vals = { Name: taxon.name,
                 rank: taxon.rank.equivalent(taxonomy),
                 parent: parent&.find }
        results = taxonomy.names_dataset.where(vals.compact)
        return results if results.count > 1

        @equivalent = results.first
      end

      # Returns the closest ancestor known in #taxonomy.
      # Can be referenced if desired
      # Access Model::Taxon through Equivalent#taxon
      # If Taxon#root? for the CatalogueOfLife::Taxon stored in #taxon is
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

      # Returns the Equivalent for the immediate ancestor if it is known
      # in the database, otherwise returns +false+.
      def parent_taxon
        lineage.missing_ancestors.empty? ? lineage.known_ancestor : false
      end

      # Updates _@taxon_ (Specify::Model::Taxon), sets +TaxonomicSerialNumber+
      # to the CatalogueOfLife id.
      # FIXME: any methods that mutate data won't work if equivalent is the
      # taxon service.
      def reference!
        return if referenced?

        return unless @equivalent

        @equivalent.TaxonomicSerialNumber = taxon.id
        @equivalent.Source = URL + API_ROUTE
        @equivalent.save
        @referenced = true
      end

      # Returns true if #taxon is referenced in the database by id
      # (+TaxonomicSerialNumber+).
      # Returns +nil+ if #find has nor been  called
      def referenced?
        return unless @equivalent

        @referenced
      end

      # Returns a hash, mapping #taxon attributes to Specify::Model::Taxon
      # attributes
      def to_model_attributes
        {
          Author: taxon.author,
          COLStatus: taxon.name_status,
          IsAccepted: taxon.accepted?, # TODO: should insert valid taxon
          IsHybrid: false, # CatalogueOfLife does not yield hybrid information
          Name: taxon.name,
          rank: rank.equivalent(taxonomy),
          RankID: rank.equivalent(taxonomy).RankID,
          Source: URL + API_ROUTE,
          TaxonomicSerialNumber: taxon.id
        }
      end

      private

      # Returns an Array of Equivalent instances for all ancestors in the
      # Taxon instances classification.
      def parse_lineage
        @lineage = Lineage.new(@taxon.classification, taxonomy)
      end
    end
  end
end
