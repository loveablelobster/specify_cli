# frozen_string_literal: true

# Tests for the
module Specify
  RSpec.describe UserType do
    let :collection do
      Model::Collection.first CollectionName: 'Test Collection'
    end

    let(:user_type) { described_class.new('guest') }

    it { expect(user_type).to respond_to :save }

    it { expect(user_type).to respond_to :view_set_dir= }

    describe '#add_app_resource_dir(values)' do
      let(:agent) { Model::Agent.first Email: 'john.doe@example.com' }
      let :values do
        {
      	  DisciplineType: 'spec type',
      	  UserType: user_type.name,
      	  IsPersonal: false,
      	  collection: collection,
      	  discipline: collection.discipline,
        }
      end

      subject do
        user_type.add_app_resource_dir(values.merge(created_by: agent,
                                                    user: agent.user))
      end

      it do
      	is_expected.to be_a(Model::AppResourceDir)
      	  .and have_attributes DisciplineType: 'spec type',
      	                       UserType: 'guest',
      	                       IsPersonal: false,
      	                       collection: collection,
      	                       discipline: collection.discipline
      end
    end

    describe '#valid?' do
      context 'when the user type name is valid' do
      	subject { user_type.valid? }

      	it { is_expected.to be_truthy }
      end

      context 'when the user type name is invalid' do
        subject { described_class.new('root').valid? }

        it { is_expected.to be_falsey }
      end
    end

    describe '#view_set_dir(collection)' do
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

    describe '#view_set(collection)' do
      subject { user_type.view_set(collection) }

      it 'returns the ViewSetObject for the given collection' do
        is_expected
          .to have_attributes Name: 'Paleo Views'
      end
    end
  end
end
