# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe Rank do
      let(:family) { Factories::Model::Rank.family }
      let(:genus) { Factories::Model::Rank.genus }
      let(:species) { Factories::Model::Rank.species }
      describe '#<=>' do
        it 'Family should be greater than Genus' do
          expect(family).to be > genus
        end

        it 'Species should be lesser than Genu' do
          expect(species).to be < genus
        end

        it 'Family should be equal to Family' do
          expect(family).to be == family
        end
      end

      describe '#equivalent'
      describe '#name'
    end
  end
end
