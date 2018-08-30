# frozen_string_literal: true

module Specify
  module Model
    # Determinations are opinions on what Specify::Model::Taxon a
    # Specify::Model::CollectionObject represents.
    #
    # A Determination belongs to a Specify::Model::CollectionObject
    # (collection_object).
    #
    # A Specify::Model::CollectionObject can have multiple determinations, only
    # one of which can be the _current_ determination.
    #
    # A Determination can belong to a Specify::Model::Taxon. If that taxon
    # is a synonym of another taxon, the Determination will also belong to
    # the accepted Taxon as the preferred_taxon.
    class Determination < Sequel::Model(:determination)
      include Createable
      include Updateable

      many_to_one :collection,
                  key: :CollectionMemberID
      many_to_one :collection_object,
                  key: :CollectionObjectID
      many_to_one :taxon,
                  key: :TaxonID
      many_to_one :preferred_taxon,
                  class: 'Specify::Model::Taxon',
                  key: :PreferredTaxonID
      many_to_one :determiner,
                  class: 'Specify::Model::Agent',
                  key: :DeterminerID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Sequel hook that assigns a GUID. Sets the collection to the
      # Specify::Model::Collection that the collection_object of +self+
      # belongs to.
      #
      # Sets the preferred_taxon to the Specify::Model::Taxon#accepted_name if
      # it has one, the Specify::Model::Taxon itself otherwise.
      #
      # Sets the _IsCurrent_ status to +true+.
      def before_create
        self[:GUID] = SecureRandom.uuid
        self.collection = collection_object&.collection
        self.preferred_taxon = taxon.accepted_name || taxon
        self[:IsCurrent] = true
        super
      end

      # Returns +true+ if +self+ is the current determination for
      # #collection_object
      def current?
        self[:IsCurrent]
      end
    end
  end
end
