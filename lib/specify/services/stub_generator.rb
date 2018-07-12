# frozen_string_literal: true

module Specify
  module Service
    # A class that generates collection object stub records in a collection.
    class StubGenerator < Service
      attr_accessor :preparation_type, :preparation_count
      attr_reader :cataloger

      def initialize(host:, database:, collection:, config: nil)
        @cataloger = nil
        @preparation_type = nil
        @preparation_count = nil
        super
      end

      # -> Model::Agent
      # <em>user_name</em>: String
      def cataloger=(user_name)
        @cataloger = Model::User.first(Name: user_name)
                                .agents_dataset.first division: division
      end

      # <em>prep_type</em>: String
      # _count_: Integer
      def preparation=(prep_type:, count: nil)
        preparation_type = Model::Preparation.first collection: collection,
                                                    Name: type
        preparation_count = count
      end

      def create(count)

      end
    end
  end
end
