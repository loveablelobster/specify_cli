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
    end
  end
end

#   DisciplineType (varchar) : 'Invertebrate Zoology' find xml where that is defined
#   UserType (varchar) : 'manager' find xml where that is defined
