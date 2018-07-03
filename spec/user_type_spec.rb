# frozen_string_literal: true

# Tests for the
module Specify
  RSpec.describe UserType do
    let :collection do
      Model::Collection.first CollectionName: 'Test Collection'
    end

    let(:user_type) { described_class.new('guest') }

    describe '#view_set_dir' do
      subject { user_type.view_set_dir(collection) }

      it do
        is_expected
          .to have_attributes DisciplineType: 'Invertebrate Paleontology',
                              IsPersonal: false,
                              UserType: 'guest',
                              collection: collection,
                              discipline: collection.discipline
      end
    end

    describe '#view_set' do
      subject { user_type.view_set(collection) }

      it 'returns the ViewSetObject for the given collection' do
        is_expected
          .to have_attributes Name: 'Paleo Views'
      end
    end
  end
end
