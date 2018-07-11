# frozen_string_literal: true

module Specify
  module Model
    #
    class AppResourceDir < Sequel::Model(:spappresourcedir)
      many_to_one :discipline, key: :DisciplineID
      many_to_one :collection, key: :CollectionID#, graph_join_type: :left
      many_to_one :user, key: :SpecifyUserID
      one_to_one :view_set_object,
                 class: 'Specify::Model::ViewSetObject',
                 key: :SpAppResourceDirID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        super
      end
    end
  end
end

#   DisciplineType (varchar) : 'Invertebrate Zoology' find xml where that is defined
#   UserType (varchar) : 'manager' find xml where that is defined
