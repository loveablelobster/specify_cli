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

      let :root_taxon do
        described_class.first Name: 'Life',
                              rank: Factories::Model::Rank.life
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

      describe '#classification' do
        context 'when it is not the root' do
          subject(:classification) { taxon.classification }

          let :be_lineage do
            include(an_instance_of(described_class) &
              have_attributes(Name: 'Life', Rank: 'Life'))
          end

          it do
            expect(classification)
              .to include(an_instance_of(described_class) &
                          have_attributes(Name: 'Life',
                                          rank: Factories::Model::Rank.life),
                          an_instance_of(described_class) &
                          have_attributes(Name: 'Animalia',
                                          rank: Factories::Model::Rank.kingdom),
                          an_instance_of(described_class) &
                          have_attributes(Name: 'Arthropoda',
                                          rank: Factories::Model::Rank.phylum),
                          an_instance_of(described_class) &
                          have_attributes(Name: 'Trilobita',
                                          rank: Factories::Model::Rank.klass),
                          an_instance_of(described_class) &
                          have_attributes(Name: 'Agnostida',
                                          rank: Factories::Model::Rank.order),
                          an_instance_of(described_class) &
                          have_attributes(Name: 'Agnostidae',
                                          rank: Factories::Model::Rank.family))
          end
        end

        context 'when it is the root' do
          subject { root_taxon.classification }

          it { is_expected.to be_empty }
        end
      end

      describe '#extinct?' do
        pending 'appropriate column missing in Specify schema'
      end

      describe '#name' do
        subject { taxon.name }

        it { is_expected.to eq 'Agnostus' }
      end

      describe '#root?' do
        context 'when it is the root' do
          subject { root_taxon.root? }

          it { is_expected.to be_truthy }
        end

        context 'when it is not the root' do
          subject { taxon.root? }

          it { is_expected.to be_falsey }
        end
      end

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
    end
  end
end
