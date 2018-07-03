# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe Collection do
      let :collection do
        described_class.first CollectionName: 'Test Collection'
      end

      describe '#view_set_dir' do
        subject { collection.view_set_dir }

        it do
          is_expected
            .to have_attributes DisciplineType: 'Invertebrate Paleontology',
                                IsPersonal: false,
                                UserType: nil,
                                collection: collection,
                                discipline: collection.discipline
        end
      end

      describe '#view_set' do
      	subject { collection.view_set }

        it do
          is_expected.to have_attributes Name: 'paleo.views'
        end
      end
    end
  end
end
