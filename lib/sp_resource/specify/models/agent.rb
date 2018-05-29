# frozen_string_literal: true

module SpResource
  module Specify
    module Model
      #
      class Agent < Sequel::Model(:agent)
        many_to_one :user, key: :SpecifyUserID
        many_to_one :division, key: :DivisionID

        def before_save
          self.Version += 1
          self.TimestampModified = Time.now
          super
        end
      end
    end
  end
end
