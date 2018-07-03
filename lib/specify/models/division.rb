# frozen_string_literal: true

module Specify
  module Model
    #
    class Division < Sequel::Model(:division)
      many_to_one :institution, key: :InstitutionID
      many_to_many :auto_numbering_schemes,
                   left_key: :DivisionID,
                   right_key: :AutoNumberingSchemeID,
                   join_table: :autonumsch_div

      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
