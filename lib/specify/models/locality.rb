# frozen_string_literal: true

module Specify
  module Model
    # Localities are places where something has been collected.
    #
    # A Locality can belong to a Specify::Model::GeographicName, and is
    # required to join a Specify::Model::CollectingEvent to a
    # Specify::Model::GeographicName.
    class Locality < Sequel::Model(:locality)
      include Createable
      include Updateable

      many_to_one :discipline,
                  key: :DisciplineID
      many_to_one :geographic_name,
                  key: :GeographyID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Sequel hook that assigns a GUID and sets the #coordinate_notation
      # to +3+.
      def before_create
        self[:GUID] = SecureRandom.uuid
        self[:SrcLatLongUnit] = 3
        super
      end

      # Creates a string representation of +self+.
      def inspect
        geo = geographic_name ? "(#{geographic_name.FullName})" : ''
        "id: #{self.LocalityID.to_s}, #{self.LocalityName} #{geo}"
      end

      # Returns an Integer in the range 0-3 that designates the format in which
      # latidtudes and longitudes are stored:
      # [0] Decimal degrees
      # [1] Degrees, minutes, and decimal seconds
      # [2] Degrees and decimal minutes
      # [3] None
      def coordinate_notation
        self[:SrcLatLongUnit]
      end
    end
  end
end
