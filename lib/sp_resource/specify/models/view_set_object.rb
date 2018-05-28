# frozen_string_literal: true

module SPResource
  module Specify
    module Model
      #
      class ViewSetObject < Sequel::Model(:spviewsetobj)
        one_to_one :app_resource_dir,
                   class: 'SPResource::Specify::Model::AppResourceDir',
                   key: :SpAppResourceDirID
        one_to_one :app_resource_data,
                   class: 'SPResource::Specify::Model::AppResourceData',
                   key: :SpViewSetObjID

        def before_save
          self.Version += 1
          self.TimestampModified = Time.now
          super
        end

        def import(views_file)
          app_resource_data.import views_file
          app_resource_dir[:Version] += 1
          app_resource_dir[:TimestampModified] = Time.now
          app_resource_dir.save
          save
        end
      end
    end
  end
end

#   Level (smallint)
#   Name (varchar)  : stores filename without extension
