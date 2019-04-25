# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe Taxon do
      let :taxon do
        described_class.create Name: 'Agnostus',
                               rank: Factories::Model::Rank.genus,
                               Author: 'Brongniart, 1822',
                               IsAccepted: true,
                               IsHybrid: false,
                               RankID: Factories::Model::Rank.genus.RankID,
                               taxonomy: Factories::Model::Taxonomy.for_tests,
                               parent: Factories::Model::Taxon.family
      end

      describe '#accepted?' do
        subject { taxon.accepted? }

        context 'when it is a valid name' do
          it { is_expected.to be_truthy }
        end

        context 'when it is not a valid name' do
          before { taxon[:IsAccepted] = false }

          it { is_expected.to be_falsey }
        end
      end

      describe '#author' do
        subject { taxon.author }

        it { is_expected.to eq 'Brongniart, 1822' }
      end

      describe '#children?' do
        subject { taxon.children? }

        context 'when it has children' do
          before do
            taxon.add_child Name: 'pisiformis',
                            rank: Factories::Model::Rank.species,
                            Author: '(Wahlenberg, 1818)',
                            IsAccepted: true,
                            IsHybrid: false,
                            RankID: Factories::Model::Rank.species.RankID,
                            taxonomy: Factories::Model::Taxonomy.for_tests
          end

          it { is_expected.to be_truthy }
        end

        context 'when it has no children' do
          it { is_expected.to be_falsey }
        end
      end

      describe '#classification'
      describe '#extinct?'
      describe '#name'
      describe '#root?'

      describe '#synonyms?'  do
        subject { taxon.synonyms? }

        context 'when it has synonyms' do
          before do
            taxon.add_synonym Factories::Model::Taxon.species
          end

          it { is_expected.to be_truthy }
        end

        context 'when it has no synonyms' do
          it { is_expected.to be_falsey }
        end
      end

      describe '#to_s'
    end
  end
end
