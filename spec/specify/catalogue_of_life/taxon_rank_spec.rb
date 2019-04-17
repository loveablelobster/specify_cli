# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonRank do
      describe '.available_ranks' do
        subject(:available_ranks) { described_class.available_ranks }

        it do
          expect(available_ranks)
            .to contain_exactly :infraspecies, :species,
                                :subgenus, :genus,
                                :subfamily, :family, :superfamily,
                                :suborder, :order, :superorder,
                                :subclass, :class, :superclass,
                                :subphylum, :phylum, :superphylum,
                                :subkingdom, :kingdom, :superkingdom
        end
      end

      describe 'ad hoc rank factory' do
        context 'when creating a valid rank' do
          subject(:species) { described_class.species }

          it do
            expect(species).to be_a(described_class) &
              have_attributes(name: :species)
          end
        end

        context 'when creating an invalid rank' do
          subject(:tribe) { described_class.tribe }

          it do
            expect { tribe }
              .to raise_error NoMethodError,
                              'undefined method `tribe\' for'\
                              ' Specify::CatalogueOfLife::TaxonRank:Class'
          end
        end

        context 'when creating a rank with a valid modifier' do
          subject(:subgenus) { described_class.subgenus }

          it do
            expect(subgenus).to be_a(described_class) &
              have_attributes(name: :subgenus)
          end
        end
      end

      describe '.prefix' do
        subject { described_class.prefix }

        it { is_expected.to contain_exactly :sub, nil, :super }
      end

      describe '#stem' do
        subject(:rank_stems) { described_class.stem }

        it do
          expect(rank_stems)
            .to contain_exactly :infraspecies, :species, :genus, :family,
                                :order, :class, :phylum, :kingdom
        end
      end

      describe '#<=>' do
        let(:superfamily) { described_class.new('Superfamily') }
        let(:family) { described_class.new('Family') }
        let(:genus) { described_class.new('Genus') }

        context 'when equal' do
      	  subject { family == described_class.new('Family') }

      		it { is_expected.to be_truthy }
      	end

      	context 'when self is lesser' do
      		subject { family < superfamily }

          it { is_expected.to be_truthy }
      	end

      	context 'when self is greater' do
      		subject { family > genus }

      		it { is_expected.to be_truthy }
      	end
      end

      describe '#equivalent' do
        subject :db_rank do
          described_class.species
                         .equivalent(Factories::Model::Taxonomy.for_tests)
        end

        it do
          expect(db_rank)
            .to be_a(Specify::Model::Rank) &
              have_attributes(Name: 'Species')
        end
      end

      describe '#position' do
        let(:subfamily) { described_class.subfamily }
        context 'when querying the stem' do
          subject { subfamily.position(:stem) }

          it { is_expected.to be 3 }
        end

        context 'when querying the prefix' do
          subject { subfamily.position(:prefix) }

          it { is_expected.to be 0 }
        end
      end

      describe '#prefix' do
        context 'when prefix is sub' do
          subject { described_class.subfamily.prefix }

          it { is_expected.to be :sub }
        end

        context 'when prefix is super' do
          subject { described_class.superfamily.prefix }

          it { is_expected.to be :super }
        end

        context 'when not prefixed' do
          subject { described_class.family.prefix }

          it { is_expected.to be_nil }
        end
      end

      describe '#stem' do
      	context 'when prefixed' do
      		subject { described_class.subfamily.stem }

      		it { is_expected.to be :family }
      	end

      	context 'when not prefixed' do
      		subject { described_class.family.stem }

      		it { is_expected.to be :family }
      	end
      end

      describe '#to_s' do
        context 'when rank is any but infraspecies' do
          subject { described_class.subfamily.to_s }

          it { is_expected.to eq 'Subfamily' }
        end

        context 'when rank is infraspecies' do
          subject { described_class.infraspecies.to_s }

          it { is_expected.to eq 'Subspecies' }
        end
      end
    end
  end
end
