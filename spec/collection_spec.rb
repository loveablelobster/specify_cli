# frozen_string_literal: true

module SPResource
  module Specify
    module Model
      RSpec.describe Collection do
        let :collection do
          described_class.first CollectionName: 'Test Collection'
        end

        it 'returns all AppResourceDir instances' do
          expect(collection.app_resource_dirs.all)
            .to include an_instance_of AppResourceDir
        end

        it 'returns the ViewSetObject for the given collection' do
          expect(collection.view_set.values)
            .to include :Name => "paleo.views"
        end
      end
    end
  end
end
