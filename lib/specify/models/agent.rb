# frozen_string_literal: true

module Specify
  module Model
    # Agents represent entities (people or organizations).
    #
    # An Agent represents a Specify::Model::User in a Specify::Model::Division;
    # that agent will be associated with every record creation and modification
    # carried out by the user in the database.
    class Agent < Sequel::Model(:agent)
      include Updateable

      many_to_one :user,
                  key: :SpecifyUserID
      many_to_one :division,
                  key: :DivisionID

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

      one_to_many :created_localities,
                  class: 'Specify::Model::Locality',
                  key: :CreatedByAgentID
      one_to_many :modified_localities,
                  class: 'Specify::Model::Locality',
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

      one_to_many :created_record_sets,
                  class: 'Specify::Model::RecordSet',
                  key: :CreatedByAgentID
      one_to_many :modified_record_sets,
                  class: 'Specify::Model::RecordSet',
                  key: :ModifiedByAgentID

      one_to_many :created_record_set_items,
                  class: 'Specify::Model::RecordSetItem',
                  key: :CreatedByAgentID
      one_to_many :modified_record_set_items,
                  class: 'Specify::Model::RecordSetItem',
                  key: :ModifiedByAgentID

      one_to_many :created_view_set_objects,
                  class: 'Specify::Model::ViewSetObject',
                  key: :CreatedByAgentID
      one_to_many :modified_view_set_objects,
                  class: 'Specify::Model::ViewSetObject',
                  key: :ModifiedByAgentID

      # Returns a String that is the first name of a person.
      def first_name
        self[:FirstName]
      end

      # Returns a String of attributes concatanated according to the
      # +formatter+.
      def full_name(formatter = nil)
        formatter ||= "#{last_name}, #{first_name} #{middle_name}"
        formatter.strip
      end

      # Returns a String that is the last name of a person or the name of an
      # organization.
      def last_name
        self[:LastName]
      end

      # Returns a String that is the middle name of a person.
      def middle_name
        self[:MiddleInitial]
      end

      # Creates a string representation of +self+.
      def to_s
        full_name
      end
    end
  end
end
