# frozen_string_literal: true

module Specify
  module Model
    # Updateable is a mixin that provides the standard #before_update hook for
    # Specify::Model classes.
    #
    # Most tables in the _Specify_ schema have a _Version_ (an Integer) that is
    # incremented for each modification and a modification timestamp. The
    # #before_update hook will set these.
    module Updateable
      # Sets the _Version_ and modification timestamp of a record.
      def before_update
        self[:Version] += 1
        self[:TimestampModified] = Time.now
        super
      end
    end
  end
end
