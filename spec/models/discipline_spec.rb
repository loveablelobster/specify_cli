# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe Discipline do
      let :discipline do
        described_class.first Name: 'Test Discipline'
      end

      describe '#view_set_dir' do
        subject { discipline.view_set_dir }

        it do
          is_expected
            .to have_attributes DisciplineType: 'Invertebrate Paleontology',
                                IsPersonal: false,
                                UserType: nil,
                                collection: nil
        end
      end

      describe '#view_set' do
        subject { discipline.view_set }

        it 'returns the ViewSetObject for the given collection' do
          is_expected.to have_attributes Name: 'Paleo Views'
        end
      end
    end
  end
end
