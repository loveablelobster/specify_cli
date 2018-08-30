# frozen_string_literal: true

module Specify
  module Model
    # Creatable is a mixin that provides the standard #before_create hook for
    # Specify::Model classes.
    #
    # Most tables in the _Specify_ schema have a _Version_ (an Integer) that is
    # incremented for each modification and a creation timestamp. The
    # #before_create hook will set these.
    module Createable
      # Initialized the _Version_ to +0+ and sets the creation timestamp of a
      # record.
      def before_create
        self[:Version] = 0
        self[:TimestampCreated] = Time.now
        super
      end
    end
  end
end
