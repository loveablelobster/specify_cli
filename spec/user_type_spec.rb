# frozen_string_literal: true

# Tests for the
module SpResource
  RSpec.describe UserType do
    let :collection do
      Specify::Model::Collection.first CollectionName: 'Test Collection'
    end

    let(:user_type) { described_class.new('guest') }

    it 'returns all AppResourceDir instances' do
      expect(user_type.app_resource_dirs(collection).all)
        .to include an_instance_of Specify::Model::AppResourceDir
    end

    it 'returns the ViewSetObject for the given collection' do
    	expect(user_type.view_set(collection).values)
    	  .to include :Name => 'Paleo Views'
    end
  end
end
