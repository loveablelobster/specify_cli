# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe CollectionObject do
      # FIXME: move to shared context
      before :all do
        cataloger =  Agent.first(FirstName: 'John', LastName: 'Specman')
        collection_a = Collection.first Code: 'SIP'
        collection_b = Collection.first Code: 'NECE'

        collection_a.add_collection_object(cataloger: cataloger,
                                           CatalogNumber: '000000011')
        collection_a.add_collection_object(cataloger: cataloger,
                                           CatalogNumber: '000000012')
        collection_b.add_collection_object(cataloger: cataloger,
                                           CatalogNumber: '000000013')
      end

      let :collection do
        Collection.first CollectionName: 'Test Collection'
      end

      context 'when adding to collection' do
        let :cataloger do
          Agent.first(FirstName: 'John', LastName: 'Specman')
        end

        context 'when passing the catalog number' do
          subject do
            collection.add_collection_object(cataloger: cataloger,
                                             CatalogNumber: '000000009')
          end

          it do
            is_expected.to have_attributes Version: 0,
                                           TimestampCreated: an_instance_of(Time),
                                           collection_member: collection,
                                           CatalogedDate: an_instance_of(Date),
                                           CatalogedDatePrecision: 1,
                                           GUID: an_instance_of(String),
                                           CatalogNumber: '000000009'
          end
        end

        context 'when passing no catalog number' do
          subject do
            collection.add_collection_object(cataloger: cataloger)
          end

          it do
            is_expected.to have_attributes Version: 0,
                                           TimestampCreated: an_instance_of(Time),
                                           collection_member: collection,
                                           CatalogedDate: an_instance_of(Date),
                                           CatalogedDatePrecision: 1,
                                           GUID: an_instance_of(String),
                                           CatalogNumber: '000000014'
          end
        end

      	context 'when collecting event is emebedded' do
          subject do
            collection.add_collection_object(cataloger: cataloger)
          end

      		it do
      		  ce = an_instance_of(CollectingEvent)
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

      # FIXME: move to shared context
      after :all do
      	CollectionObject.dataset.delete
      	CollectingEvent.dataset.delete
      end
    end
  end
end
