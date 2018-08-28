# frozen_string_literal: true

module Specify
  module Model
    # Mixin that...
    module Updateable
      #
      def before_update
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end
    end
  end
end
