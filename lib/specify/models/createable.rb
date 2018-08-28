# frozen_string_literal: true

module Specify
  module Model
    # Mixin that...
    module Createable
      #
      def before_create
        self.Version = 0
        self.TimestampCreated = Time.now
        super
      end
    end
  end
end
