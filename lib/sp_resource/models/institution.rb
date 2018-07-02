# frozen_string_literal: true

module Specify
  module Model
    #
    class Institution < Sequel::Model(:institution)
      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
