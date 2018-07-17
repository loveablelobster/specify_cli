# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for geographic names (countries, states, counties)
    class GeographicName < Sequel::Model(:geography)
      many_to_one :geography, key: :GeographyTreeDefID
      many_to_one :rank,
                  class: 'Specify::Model::AdministrativeDivision',
                  key: :GeographyTreeDefItemID
      many_to_one :parent, class: self, key: :ParentID
      many_to_one :accepted_name, class: self, key: :AcceptedID
      one_to_many :children, class: self, key: :ParentID
      one_to_many :synonyms, class: self, key: :AcceptedID
      one_to_many :localities, key: :GeographyID

      # create: rank.add_taxon or parent.add_child
      def before_create
        self.geography = rank&.geography ||
                         parent.rank&.geography
        self.Version = 0
        self.TimestampCreated = Time.now
        self.GUID = SecureRandom.uuid
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      def inspect
        "id: #{self.GeographyID}; Full Name: '#{self.FullName}'"
      end

      def children?
        !children.empty?
      end
    end
  end
end
