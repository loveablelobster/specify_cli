# frozen_string_literal: true

module Specify
  module Model
    # PreparationTypes, are categopries of Specify::Model::Preparation.
    # A PreparationType providess a controlled vocabulary for available types of
    # preparations, where the element in the controlled vocabulary is the #name.
    class PreparationType < Sequel::Model(:preptype)
      include Createable
      include Updateable

      many_to_one :collection,
                  key: :CollectionID
      one_to_many :preparations,
                  key: :PrepTypeID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Returns a String with the name of +self+ (a short name that is an
      # element of a controlled vocabulary).
      def name
        self[:Name]
      end
    end
  end
end
