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
      # The taxon that +self+ has found (or created); if +self+ has been
      # initialized with a Model::Taxon representation, then this will be a
      # CatalogueOfLife::Taxon. If +self+ has been initialized with a
      # CatalogueOfLife::Taxon, this will be a Model::Taxon.
      attr_reader :equivalent

      # Tthe name (a String) of the taxon (common to both #taxon and
      # #equivalent).
      attr_reader :name

      # The rank common to both #taxon and #equivalent. This will be a
      # CatalogueOfLife::Rank for the external representation, a Model::Rank
      # for the internal representation.
      # FIXME: should always be a CatalogueOfLife::Rank
      attr_reader :rank

      # The taxon with which +self+ has been initialized. If this is a
      # Model::Taxon, then #equivalent will be a CatalogueOfLife::Taxon
      # that +self+ will try to find. If it is CatalogueOfLife::Taxon, then
      # +self+ can find, create, and update a Model::Taxon for #equivalent.
      attr_reader :taxon

      # The Specify::Model::Taxonomy.
      attr_reader :taxonomy

      # Returns a new instance.
      # +taxonomy+ is a Model::Taxonomy
      # +taxon+ is a CatalogueOfLife::Taxon or Model::Taxon.
      def initialize(taxonomy, taxon)
        @taxonomy = taxonomy
        @taxon = taxon
        @equivalent = nil
        @name = taxon.name
        @rank = taxon.rank
        @lineage = nil
      end

      # Returns an Array of Equivalent instances in the ancestor lineage
      # ordered by #rank (descending).
      def ancestors
        lineage.ancestors
      end

      # Creates a Model::Taxon for #equivalent if #equivalent is mutable
      # (#taxon is external). If _parent_ (an iEquivalent) is passed,
      # #equivalent will be created as a child in it. If <em>fill_lineage</em>
      # is set to +true+, any taxa in missing in the classification of #taxon in
      # the database taxonomy will be created.
      def create(parent = nil, fill_lineage: false)
        raise 'can\'t mutate Catalogue of life' unless mutable?

        parent ||= parent_taxon
        if parent
          @equivalent = parent.equivalent.add_child to_model_attributes
        elsif fill_lineage
          @equivalent = lineage.create.last.add_child to_model_attributes
        else
          # TODO: consolidate into error constants
          raise 'Immidiate ancestor missing'
        end
      end

      # Returns the external concept for the taxon, i.e. the
      # CatalogueOfLife::Taxon.
      def external
        taxon.is_a?(CatalogueOfLife::Taxon) ? taxon : equivalent
      end

      # Finds the #equivalent of #taxon.
      def find(parent = nil)
        find_by_id || find_by_values(parent)
      end

      # Finds the #equivalent of #taxon by the service_url (URL + API_ROUTE)
      # and +id+ attribute (the Catalogue Of Life id).
      def find_by_id
        found = target == :internal ? db_find_by_id : col_find_by_id
        @equivalent = found
      end

      # Finds the taxon for +self+ in #taxonomy by _name_, _rank_, and
      # optionally _parent_, if a Equivalent as passed in as the +parent+
      # argument.
      def find_by_values(parent = nil)
        @equivalent = if target == :internal
                        db_find_by_values(parent)
                      else
                        col_find_by_values
                      end
      end

      # Returns an OpenStruct with the IDs for the #taxon +self+ has been
      # initialized with and the #equivalent.
      def id
        OpenStruct.new(taxon: taxon.id, equivalent: equivalent&.id)
      end

      # Returns the internal concept for the taxon, i.e. the Model::Taxon.
      def internal
        taxon.is_a?(Model::Taxon) ? taxon : equivalent
      end

      # Returns an Equivalent that is the closest ancestor of #taxon known in
      # other of the match; if #taxon is a CatalogueOfLife::Taxon, it would be
      # the closest known ancestor from the Model::Taxon instances in #taxonomy.
      # Can be referenced if desired.
      # If Taxon#root? for the CatalogueOfLife::Taxon stored in #taxon is
      # +true+ this will also return +false+.
      def known_ancestor
        lineage.known_ancestor
      end

      # Returns a CatalogueOfLife::Lineage with all Taxon instances in from
      # the direct ancestor of +self+ to the root of the classification.
      def lineage
        @lineage || parse_lineage
      end

      # Returns an Array of Equivalent instances, ordered by #rank (ascending),
      # whose #equivalent attributes have not been found.
      def missing_ancestors
        lineage.missing_ancestors
      end

      # Returns +true+ if there is write access to the #equivalent (it is an
      # internal resource).
      def mutable?
        equivalent == internal
      end

      # Returns the Equivalent for the immediate ancestor if it is known,
      # otherwise returns +false+.
      def parent_taxon
        lineage.missing_ancestors.empty? ? lineage.known_ancestor : false
      end

      # Updates #internal (Specify::Model::Taxon), sets +TaxonomicSerialNumber+
      # to the CatalogueOfLife id.
      def reference!
        find unless equivalent

        internal.taxonomic_serial_number = external.id
        internal.source = URL + API_ROUTE
        internal.save
      end

      # Returns true if #equivalent is referenced in the database by id
      # (+TaxonomicSerialNumber+).
      # Returns +nil+ if #find has nor been  called
      def referenced?
        find unless equivalent
        internal&.taxonomic_serial_number == external&.id
      end

      # Determines the polarity of +self+; returns +:internal+ if +self+ has
      # been initialized with an external #taxon and all actions (find, create,
      # update) are targeted towards an internal #equivalent. Returns
      # +:external+ if +self+ has been initialized with an internal #taxon and
      # actions are targeted towards an external #equivalent.
      def target
        taxon == external ? :internal : :external
      end

      # Returns a hash, mapping #taxon attributes to Specify::Model::Taxon
      # attributes
      def to_model_attributes
        {
          author: taxon.author,
          name_status: taxon.name_status,
          accepted: taxon.accepted?, # TODO: should insert valid taxon
          hybrid: taxon.hybrid?,
          name: taxon.name,
          rank: rank.equivalent(taxonomy),
          source: taxon.source,
          taxonomic_serial_number: taxon.id
        }
      end

      private

      def col_find_by_id
        return unless taxon.taxonomic_serial_number

        Request.by_id(taxon.taxonomic_serial_number).taxon
      end

      def db_find_by_id
        taxonomy.names_dataset
                .first(Source: URL + API_ROUTE, TaxonomicSerialNumber: taxon.id)
      end

      def col_find_by_values(_ = nil)
        col = Request.new do |req|
          req.name = name
          req.rank = rank.equivalent.name
          # FIXME: Does CoL support searching in taxon?
        end
        col.taxon
      end

      def db_find_by_values(parent = nil)
        vals = { Name: taxon.name,
                 rank: taxon.rank.equivalent(taxonomy),
                 parent: parent&.find }
        results = taxonomy.names_dataset.where(vals.compact)
        raise 'Ambiguous match' if results.count > 1

        results.first
      end

      # Returns an Array of Equivalent instances for all ancestors in the
      # Taxon instances classification.
      def parse_lineage
        @lineage = Lineage.new(@taxon.classification, taxonomy)
      end
    end
  end
end
