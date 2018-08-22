# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for geographies (geography trees).
    class AdministrativeDivision < Sequel::Model(:geographytreedefitem)
      many_to_one :geography, key: :GeographyTreeDefID
      one_to_many :geographic_names, key: :GeographyTreeDefItemID
      one_to_one :child, class: self, key: :ParentItemID
      many_to_one :parent, class: self, key: :ParentItemID

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      def name
        self.Name
      end
    end
  end
end
