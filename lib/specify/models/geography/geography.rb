# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model for geographies (geography trees).
    class Geography < Sequel::Model(:geographytreedef)
      include TreeQueryable

      one_to_many :disciplines, key: :GeographyTreeDefID
      one_to_many :ranks,
                  class: 'Specify::Model::AdministrativeDivision',
                  key: :GeographyTreeDefID
      one_to_many :names,
                  class: 'Specify::Model::GeographicName',
                  key: :GeographyTreeDefID

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
