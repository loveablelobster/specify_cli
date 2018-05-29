# frozen_string_literal: true

module SpResource
  module Specify
    module Model
      RSpec.describe Discipline do
        let :discipline do
          described_class.first Name: 'Test Discipline'
        end

        it 'returns all AppResourceDir instances' do
          expect(discipline.app_resource_dirs.all)
            .to include an_instance_of AppResourceDir
        end

        it 'returns the ViewSetObject for the given collection' do
          expect(discipline.view_set.values)
            .to include :Name => "paleo.views"
        end
      end
    end
  end
end
