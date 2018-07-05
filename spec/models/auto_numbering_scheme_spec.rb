# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe AutoNumberingScheme do
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

      let :auto_numbering_scheme do
        Collection.first(CollectionName: 'Test Collection')
                  .auto_numbering_scheme
      end

      describe '#max' do
        subject { auto_numbering_scheme.max }
        it { is_expected.to eq '000000013' }
      end

      describe '#increment' do
      	subject { auto_numbering_scheme.increment }

      	it { is_expected.to eq '000000014' }
      end

      # FIXME: move to shared context
      after :all do
      	CollectionObject.dataset.delete
      	CollectingEvent.dataset.delete
      end
    end
  end
end
