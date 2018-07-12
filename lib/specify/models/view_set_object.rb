# frozen_string_literal: true

module Specify
  module Model
    # Sequel::Model class for view set objects.
    class ViewSetObject < Sequel::Model(:spviewsetobj)
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

      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        super
      end

      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      # -> Model::ViewSetObject
      # Persists _file_ as a blob the database.
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
