# frozen_string_literal: true

module Specify
  module Model
    #
    class CommonName < Sequel::Model(:commonnametx)
      many_to_one :taxon, key: :TaxonID

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
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
