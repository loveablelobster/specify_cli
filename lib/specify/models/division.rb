# frozen_string_literal: true

module Specify
  module Model
    # Divisions are the next highest level of scope within a Specify::Database.
    #
    # A Division belongs to the single instance of Specify::Model::Institution
    # within a Specify::Database.
    #
    # A Division has one or more instances of Specify::Model::Discipline.
    #
    # Specify::Model::Agent instances are scoped to the Division level.
    class Division < Sequel::Model(:division)
      include Updateable

      many_to_one :institution,
                  key: :InstitutionID
      many_to_many :auto_numbering_schemes,
                   left_key: :DivisionID,
                   right_key: :AutoNumberingSchemeID,
                   join_table: :autonumsch_div
      one_to_many :accessions,
                  key: :DivisionID
    end
  end
end
