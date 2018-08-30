# frozen_string_literal: true

module Specify
  module Model
    # Institution is the highest level of scope within a Specify::Database.
    #
    # A Specify::Database has a single instance of Institution. The Institution
    # has one or more instances of Specify::Model::Division.
    class Institution < Sequel::Model(:institution)
      include Updateable
    end
  end
end
