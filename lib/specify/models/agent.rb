# frozen_string_literal: true

module Specify
  module Model
    #
    class Agent < Sequel::Model(:agent)
      many_to_one :user, key: :SpecifyUserID
      many_to_one :division, key: :DivisionID

      one_to_many :created_autonumbering_schemes,
                  class: 'Specify::Model::AutonumberinScheme',
                  key: :CreatedByAgentID
      one_to_many :modified_autonumbering_schemes,
                  class: 'Specify::Model::AutonumberinScheme',
                  key: :ModifiedByAgentID

      one_to_many :created_collecting_events,
                  class: 'Specify::Model::CollectingEvent',
                  key: :CreatedByAgentID
      one_to_many :modified_collecting_events,
                  class: 'Specify::Model::CollectingEvent',
                  key: :ModifiedByAgentID

      one_to_many :created_colection_objects,
                  class: 'Specify::Model::CollectionObject',
                  key: :CreatedByAgentID
      one_to_many :modified_colection_objects,
                  class: 'Specify::Model::CollectionObject',
                  key: :ModifiedByAgentID

      one_to_many :created_preparations,
                  class: 'Specify::Model::Preparation',
                  key: :CreatedByAgentID
      one_to_many :modified_preparations,
                  class: 'Specify::Model::Preparation',
                  key: :ModifiedByAgentID

      one_to_many :created_preparation_types,
                  class: 'Specify::Model::PreparationType',
                  key: :CreatedByAgentID
      one_to_many :modified_preparation_types,
                  class: 'Specify::Model::PreparationType',
                  key: :ModifiedByAgentID

      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
