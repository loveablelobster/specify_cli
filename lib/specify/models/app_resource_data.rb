# frozen_string_literal: true

module Specify
  module Model
    class AppResourceData < Sequel::Model(:spappresourcedata)
      many_to_one :viewsetobj,
                  class: 'Specify::Model::ViewSetObject',
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

      def import(data_file)
        self.data = Sequel.blob(File.read(data_file))
        save
      end
    end
  end
end
