# frozen_string_literal: true

module Specify
  module Model
    # AppResourceDirs associate instances of Specify::Model::ViewSetObject
    # or AppResource (not implemented) with other Specify::Model classes,
    # such as Specify::Model::Collection, Specify::Model::Discipline, or
    # Specify::Model::User, as well as the abstract/custom Specify::UserType,
    # and are used to locate a relevant ViewSetObject or AppResource for a
    # given instance of one of these classes.
    #
    # Resources (ViewSetObjects or AppResurces) are usually _XML_ files used
    # by the _Specify_ application. The files are stored in the AppResourceDirs
    # associated #view_set_object's or AppResource (not implemented)
    # Specify::Model::AppResourceData.
    class AppResourceDir < Sequel::Model(:spappresourcedir)
      include Createable
      include Updateable

      many_to_one :discipline,
                  key: :DisciplineID
      many_to_one :collection,
                  key: :CollectionID
      many_to_one :user,
                  key: :SpecifyUserID
      one_to_one :view_set_object,
                 class: 'Specify::Model::ViewSetObject',
                 key: :SpAppResourceDirID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Returns a String that is the discipline type (same as
      # Specify::Model::Discipline#name) +self+ belongs to.
      def discipline_type
        self[:DisciplineType]
      end
    end
  end
end
