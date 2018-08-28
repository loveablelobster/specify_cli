# frozen_string_literal: true

module Specify
  module Model
    # ViewSetObjects represent Specify user forms (views). The actual views are
    # _.views.xml_ files that are stored as blobs in the database.
    class ViewSetObject < Sequel::Model(:spviewsetobj)
      include Createable
      include Updateable

      many_to_one :app_resource_dir,
                  class: 'Specify::Model::AppResourceDir',
                  key: :SpAppResourceDirID
      one_to_one :app_resource_data,
                 class: 'Specify::Model::AppResourceData',
                 key: :SpViewSetObjID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Persists +file+ (a _.views.xml_ file) as a blob in the database.
      def import(file)
        app_resource_data.import file
        app_resource_dir[:Version] += 1
        app_resource_dir[:TimestampModified] = Time.now
        app_resource_dir.save
        save
      end
    end
  end
end
