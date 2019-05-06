# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe Rank do
      describe '#<=>' do
        it 'Family should be greater than Genus' do
          expect(Factories::Model::Rank.family)
            .to be > Factories::Model::Rank.genus
        end

        it 'Species should be lesser than Genu' do
          expect(Factories::Model::Rank.species)
            .to be < Factories::Model::Rank.genus
        end

        it 'Family should be equal to Family' do
          expect(Factories::Model::Rank.family)
            .to be == Factories::Model::Rank.family
        end
      end

      describe '#equivalent'
      describe '#name'
    end
  end
end
