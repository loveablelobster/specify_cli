# frozen_string_literal: true

module Specify
  module Model
    #
    class Division < Sequel::Model(:division)
      many_to_one :institution, key: :InstitutionID

      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
