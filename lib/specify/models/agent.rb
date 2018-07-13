# frozen_string_literal: true

module Specify
  module Model
    #
    class Agent < Sequel::Model(:agent)
      many_to_one :user, key: :SpecifyUserID
      many_to_one :division, key: :DivisionID

      one_to_many :created_accessions,
                  class: 'Specify::Model::Accession',
                  key: :CreatedByAgentID
      one_to_many :modified_accessions,
                  class: 'Specify::Model::Accession',
                  key: :ModifiedByAgentID

      one_to_many :created_app_resource_data,
                  class: 'Specify::Model::AppResourceData',
                  key: :CreatedByAgentID
      one_to_many :modified_app_resource_data,
                  class: 'Specify::Model::AppResourceData',
                  key: :ModifiedByAgentID

      one_to_many :created_app_resource_dirs,
                  class: 'Specify::Model::AppResourceDir',
                  key: :CreatedByAgentID
      one_to_many :modified_app_resource_dirs,
                  class: 'Specify::Model::AppResourceDir',
                  key: :ModifiedByAgentID

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

      one_to_many :created_determinations,
                  class: 'Specify::Model::Determination',
                  key: :CreatedByAgentID
      one_to_many :modified_determinations,
                  class: 'Specify::Model::Determination',
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

      one_to_many :created_view_set_objects,
                  class: 'Specify::Model::ViewSetObject',
                  key: :CreatedByAgentID
      one_to_many :modified_view_set_objects,
                  class: 'Specify::Model::ViewSetObject',
                  key: :ModifiedByAgentID

      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
