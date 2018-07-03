# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe CollectionObject do
      let :collection do
        Collection.first CollectionName: 'Test Collection'
      end

      it 'bla' do
        p collection.add_collection_object CatalogNumber: '1'
      end

      context 'when adding to collection' do
      	context 'when collecting event is emebedded' do
      		subject do
      		  collection.add_collection_object(CatalogNumber: '1')
      		end

      		it do
      		  ce = an_instance_of(Specify::Model::CollectingEvent)
      			is_expected.to have_attributes collecting_event: ce
      		end
      	end

      	context 'when collecting event is not embedded' do
          subject do
          	Collection.first(Code: 'NECE')
          	          .add_collection_object(CatalogNumber: '2')
          end

          it do
            is_expected.to have_attributes collecting_event: nil
          end
      	end
      end
    end
  end
end
