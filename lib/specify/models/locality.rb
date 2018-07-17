# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for geographic names (countries, states, counties)
    class Locality < Sequel::Model(:locality)
      many_to_one :discipline, key: :DisciplineID
      many_to_one :geographic_name, key: :GeographyID

      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # create: rank.add_taxon or parent.add_child
      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        self.GUID = SecureRandom.uuid
        self.SrcLatLongUnit = 3
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      def inspect
        'id: ' + self.LocalityID.to_s + '; ' + self.LocalityName
          + ' (' + geographic_name.FullName + ')'
      end
    end
  end
end
