# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe Taxon do
      let(:astacidae) { described_class.new(result :valid_family) }
      let(:astacus) { described_class.new(result :valid_genus) }
      let(:astacus_astacus) { described_class.new(result :valid_species) }
      let(:astacus_edwardsi) { described_class.new(result :extinct_species) }
      let(:cancer_fimbriatus) { described_class.new(result :synonym) }
      let(:cancer_pagurus) { described_class.new(result :with_synonyms) }
      let(:procambarus_l_l) { described_class.new(result :subspecies) }
      let(:p_lucifugus) { described_class.new(result :species_in_subgenus)}
      let(:animalia) { described_class.new(result :root) }

      context 'when calling a method not represented in #full_response' do
        subject(:no_method) { cancer_pagurus.no_such_key }

        it do
          expect { no_method }
            .to raise_error NoMethodError
        end
      end

      context 'when calling a method represented by a key in #full_response' do
        context 'when the key has a value' do
          subject { cancer_pagurus.name_html }

          it { is_expected.to eq '<i>Cancer pagurus</i> Linnaeus, 1758' }
        end

        context 'when the key has no value' do
          subject { cancer_pagurus.subgenus }

          it { is_expected.to be_nil }
        end

        context 'when the value is empty' do
          subject { cancer_pagurus.infraspecies }

          it { is_expected.to be_nil }
        end
      end

      describe '#accepted?' do
        context 'when it is accepted' do
          subject { cancer_pagurus.accepted? }

          it { is_expected.to be_truthy }
        end

        context 'when it is not accepted' do
          subject { cancer_fimbriatus.accepted? }

          it { is_expected.to be_falsey }
        end
      end

      describe '#author' do
        context 'when the taxon response has an author' do
          subject { cancer_pagurus.author }

          it { is_expected.to eq 'Linnaeus, 1758' }
        end

        context 'when the taxon response has no author' do
          subject { astacidae.author }

          it { is_expected.to be_nil }
        end
      end

      describe '#children' do
        context 'when it does not have children' do
          subject { astacus_astacus.children }

          it { is_expected.to be_empty }
        end

        context 'when it has children' do
          subject { astacus.children }

          let :be_child_responses do
            a_collection_including(
              an_instance_of(described_class) &
                have_attributes(id: '526387756aa5574c4879c6cc114248fd'),
              an_instance_of(described_class) &
                have_attributes(id: '8d133bcc525ea8e040d6858ed52625bd'),
              an_instance_of(described_class) &
                have_attributes(id: '386243cced4e42f3a15453c8ffad5dc4'),
              an_instance_of(described_class) &
                have_attributes(id: '54fe3bc380732201105cdde261a855d5'),
              an_instance_of(described_class) &
                have_attributes(id: 'ed2a9af088ea52cc1907f2b552602a48'),
              an_instance_of(described_class) &
                have_attributes(id: '3d050be53ecfb6c9a33d8069532e43e4')
              )
          end

          it { is_expected.to be_child_responses }
        end
      end

      describe '#children?' do
        context 'when it has children' do
          subject { astacus.children? }

          it { is_expected.to be_truthy }
        end

        context 'when it does not have children' do
          subject { astacus_astacus.children? }

          it { is_expected.to be_falsey }
        end
      end

      describe '#classification' do
        context 'when there is no subgenus' do
          subject(:ancestors) { astacidae.classification }

          it do
            expect(ancestors).to contain_exactly(
              an_instance_of(described_class) &
                have_attributes(name: 'Animalia'),
              an_instance_of(described_class) &
                have_attributes(name: 'Arthropoda'),
              an_instance_of(described_class) &
                have_attributes(name: 'Malacostraca'),
              an_instance_of(described_class) &
                have_attributes(name: 'Decapoda'),
              an_instance_of(described_class) &
                have_attributes(name: 'Astacoidea')
            )
          end
        end

        context 'when there is a subgenus and subgenera are not skipped' do
          subject :ancestors do
            procambarus_l_l.classification(skip_subgenera: false)
          end

          it do
            expect { ancestors }
              .to raise_error RuntimeError, ResponseError::SERVICE_RELIABILITY
          end
        end

        context 'when there is a subgenus and subgenera are skipped' do
          subject :ancestors do
            procambarus_l_l.classification(skip_subgenera: true)
          end

          it do
            expect(ancestors).to contain_exactly(
              an_instance_of(described_class) &
                have_attributes(name: 'Animalia'),
              an_instance_of(described_class) &
                have_attributes(name: 'Arthropoda'),
              an_instance_of(described_class) &
                have_attributes(name: 'Malacostraca'),
              an_instance_of(described_class) &
                have_attributes(name: 'Decapoda'),
              an_instance_of(described_class) &
                have_attributes(name: 'Astacoidea'),
              an_instance_of(described_class) &
                have_attributes(name: 'Cambaridae'),
              an_instance_of(described_class) &
                have_attributes(name: 'Procambarus'),
              an_instance_of(described_class) &
                have_attributes(name: 'lucifugus')
            )
          end

          it do
            expect(ancestors).not_to include(
              an_instance_of(described_class) &
                have_attributes(rank: Rank.subgenus)
            )
          end
        end

        context 'when it is the root' do
          subject { animalia.classification }

          it { is_expected.to be_empty }
        end
      end

      describe '#common _name' do
        context '#when it has common names' do
          subject(:vernacular) { cancer_pagurus.common_names }

          it do
            expect(vernacular)
              .to include a_hash_including(name: 'grote noordzeekrab',
                                           language: 'Dutch',
                                           country: nil,
                                           references: an_instance_of(Array)),
                          a_hash_including(name: 'taskekrabbe',
                                           language: 'Danish',
                                           country: nil,
                                           references: an_instance_of(Array))
          end
        end

        context '#when it does not have common names' do
          subject { astacus_astacus.common_names }

          it { is_expected.to be_empty }
        end
      end

      describe '#extinct?' do
        context 'when it is extant)' do
          subject { astacus_astacus.extinct? }

          it { is_expected.to be_falsey }
        end

        context 'when it is extinct' do
          subject { astacus_edwardsi.extinct? }

          it { is_expected.to be_truthy }
        end

        context 'when it is a synonym' do
          subject { cancer_fimbriatus.extinct? }

          it { is_expected.to be_nil }
        end
      end

      describe '#name' do
        context 'when it is an infraspecies' do
          subject { procambarus_l_l.name }

          it { is_expected.to eq 'lucifugus' }
        end

        context 'when it is a species' do
          subject { astacus_astacus.name }

          it { is_expected.to eq 'astacus' }
        end

        context 'when it is a subgenus' do
          pending 'Subgenera are broken in the CatalogueOfLife API'
        end

        context 'when it is a genus' do
          subject { astacus.name }

          it { is_expected.to eq 'Astacus' }
        end
      end

      describe '#parent' do
        context 'when it is the root' do
          subject { animalia.parent }

          it { is_expected.to be_nil }
        end

        context 'when it is below the root' do
          subject(:parent) { astacus_astacus.parent }

          it do
            expect(parent).to be_a(Taxon) &
              have_attributes(name: 'Astacus')
          end
        end

        context 'when the direct parent is a subgenus and skip_subgenera is'\
                ' true' do
          subject(:parent) { p_lucifugus.parent }

          it do
            expect(parent).to be_a(Taxon) &
              have_attributes(name: 'Procambarus')
          end
        end

        context 'when the direct parent is a subgenus and skip_subgenera is'\
                ' false' do
          subject(:parent) { p_lucifugus.parent(skip_subgenera: false) }

          it do
            expect { parent }
              .to raise_error RuntimeError, ResponseError::SERVICE_RELIABILITY
          end
        end
      end

      describe '#rank' do
        subject(:subsp_rank) { procambarus_l_l.rank }

        it do
          expect(subsp_rank).to be_a(Rank) &
            have_attributes(name: :infraspecies)
        end
      end

      describe '#root?' do
        context 'when the resonse represent the root' do
          subject { animalia.root? }

          it { is_expected.to be_truthy }
        end

        context 'when the response does not represent the root' do
          subject { astacidae.root? }

          it { is_expected.to be_falsey }
        end

        context 'when the response has no classificatiom (synonym)' do
          subject { cancer_fimbriatus.root? }

          it { is_expected.to be_nil }
        end
      end

      describe '#synonyms' do
        context 'when it has no synonyms' do
          subject { astacus_astacus.synonyms }

          it { is_expected.to be_empty }
        end

        context 'when it has synonyms' do
          subject { cancer_pagurus.synonyms }

          let :be_synonym_responses do
            a_collection_including(
              an_instance_of(described_class) &
                have_attributes(id: 'd81941a10d07fcc621073de9cdefca96'),
              an_instance_of(described_class) &
                have_attributes(id: '4a6de56affa3de0e027145d2d7136f2a'),
              an_instance_of(described_class) &
                have_attributes(id: 'cc57308ba2f409c765bbdaedcbaa1f78')
              )
          end

          it { is_expected.to be_synonym_responses }
        end
      end

      describe '#synonyms?' do
        context 'when it has no synonyms attribute' do
          subject { astacus.synonyms? }

          it { is_expected.to be_nil }
        end

        context 'when it has no synonyms' do
          subject { astacus_astacus.synonyms? }

          it { is_expected.to be_falsey }
        end

        context 'when it has synonyms' do
          subject { cancer_pagurus.synonyms? }

          it { is_expected.to be_truthy }
        end
      end
    end
  end
end
