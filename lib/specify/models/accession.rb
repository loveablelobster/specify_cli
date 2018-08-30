# frozen_string_literal: true

module Specify
  module Model
    # Accessions are _interactions_ that represent the formal transferral of
    # ownership of one or more #collection_objects (instances of
    # Specify::Model::CollectionObjects).
    #
    # An Accession belongs to a #division (an instance of
    # Specify::Model::Division).
    class Accession < Sequel::Model(:accession)
      include Createable
      include Updateable

      many_to_one :division,
                  key: :DivisionID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID
      one_to_many :collection_objects,
                  key: :AccessionID

      # Returns a String with the accession number (a number under which all
      # information relating to an accession is filed).
      def number
        self[:AccessionNumber]
      end
    end
  end
end
