# frozen_string_literal: true

module Specify
  module Model
    # A Sequel::Model representing collection objects
    class Determination < Sequel::Model(:determination)
      many_to_one :collection, key: :CollectionMemberID
      many_to_one :collection_object, key: :CollectionObjectID
      many_to_one :taxon, key: :TaxonID
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

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        self.GUID = SecureRandom.uuid
        self.collection = collection_object&.collection
        self.preferred_taxon = taxon.accepted_name || taxon
        self.IsCurrent = 1
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
