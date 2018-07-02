# frozen_string_literal: true

module Specify
  module Model
    class AppResourceData < Sequel::Model(:spappresourcedata)
      one_to_one :viewsetobj, key: :SpViewSetObjID

      def before_save
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
