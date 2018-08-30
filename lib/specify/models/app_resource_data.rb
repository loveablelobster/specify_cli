# frozen_string_literal: true

module Specify
  module Model
    # AppResourceData hold data the _Specify_ application uses (usually in the
    # form of _XML_ files that are stored as blobs).
    #
    # An AppResourceData belongs to a #viewsetobj (an instance of
    # Specify::Model::ViewSetObject) or AppResource (not implemented).
    class AppResourceData < Sequel::Model(:spappresourcedata)
      include Createable
      include Updateable

      many_to_one :viewsetobj,
                  class: 'Specify::Model::ViewSetObject',
                  key: :SpViewSetObjID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Stores the contents of +data_file+ (typically an _.xml_ file) as a
      # blob in the database.
      def import(data_file)
        self.data = Sequel.blob(File.read(data_file))
        save
      end
    end
  end
end
