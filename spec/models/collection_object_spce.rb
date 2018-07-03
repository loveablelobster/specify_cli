# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe CollectionObject do
      let :collection do
        Collection.first CollectionName: 'Test Collection'
      end

      it 'bla' do
        p collection
        p collection.add_collection_object CatalogNumber: '1'
      end
    end
  end
end
