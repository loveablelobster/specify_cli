# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonEquivalent do
      let :asaphida_eq do
        described_class.new(spec_taxonomy, response(:asaphida))
      end

      let :asaphoidea_eq do
        described_class.new(spec_taxonomy, response(:asaphoidea))
      end

      let :asaphidae_eq do
        described_class.new(spec_taxonomy, response(:asaphidae))
      end

      let :asaphus_eq do
        described_class.new(spec_taxonomy, response(:asaphus))
      end

      let :asaphus_expansus_eq do
        described_class.new(spec_taxonomy, response(:asaphus_expansus))
      end

      let :raymondaspis_eq do
        described_class.new(spec_taxonomy, response(:raymondaspis))
      end

      let :animalia_eq do
        described_class.new(spec_taxonomy, response(:root))
      end

      describe '#ancestors' do
        subject { asaphus_eq.ancestors }

        let :contain_ancestors do
          contain_exactly(an_instance_of(TaxonEquivalent) &
                          have_attributes(name: 'Asaphidae'),
                          an_instance_of(TaxonEquivalent) &
                          have_attributes(name: 'Asaphoidea'),
                          an_instance_of(TaxonEquivalent) &
                          have_attributes(name: 'Asaphida'),
                          an_instance_of(TaxonEquivalent) &
                          have_attributes(name: 'Trilobita'),
                          an_instance_of(TaxonEquivalent) &
                          have_attributes(name: 'Arthropoda'),
                          an_instance_of(TaxonEquivalent) &
                          have_attributes(name: 'Animalia'))
        end

        it { is_expected.to contain_ancestors }
      end

      describe '#concept_id' do
        subject { asaphida_eq.concept_id }

        it { is_expected.to eq '5ac1330933c62d7d617a8d4a80dcecf3' }
      end

      describe '#create' do

      end

      describe '#find'

      describe '#find_by_id' do
        context 'when the taxon with concept id exists' do
          subject(:exact_match) { asaphida_eq.find_by_id }

          let :be_asaphida do
            be_a(Model::Taxon) & have_attributes(Name: 'Asaphida')
          end

          it { is_expected.to be_asaphida }

          it do
            expect {exact_match}
              .to change(asaphida_eq, :referenced?)
              .from(be_falsey)
              .to(be_truthy)
          end
        end

        context 'when the taxon with concept id does not exist' do
          subject { asaphoidea_eq.find_by_id }

          it { is_expected.to be_nil }
        end
      end

      describe '#find_by_values' do
        context 'when no parent is given and the taxon is found' do
          subject(:find_asaphoidea) { asaphoidea_eq.find_by_values }

          it do
            expect(find_asaphoidea).to be_a(Model::Taxon) &
              have_attributes(Name: 'Asaphoidea')
          end

          it 'is expected to change #taxon'
        end

        context 'when parent is given and the taxon is found'

        context 'when the taxon is not found'

        context 'when multiple matches are found'
      end

      describe '#known_ancestor' do
        context 'when root' do
          subject(:root) { animalia_eq.known_ancestor }

          it { is_expected.to be_nil }
        end

        context 'when below root and immediate ancestor is found by id' do
          subject(:match) { asaphus_eq.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Asaphidae')
          end

          it do
            expect(match.taxon).to be_a(Model::Taxon) &
              have_attributes(Name: 'Asaphidae',
                              Source: 'http://webservice.catalogueoflife.org/'\
                                      'col/webservice',
                              TaxonomicSerialNumber: '65dabea41cd4470ce'\
                                                     '498767d730f5c6f')
          end
        end

        context 'when below root and immediate ancestor is found by'\
                ' name, rank, parent' do
          subject(:match) { asaphidae_eq.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Asaphoidea')
          end

          it do
            expect(match.taxon).to be_a(Model::Taxon) &
              have_attributes(Name: 'Asaphoidea',
                              Source: nil,
                              TaxonomicSerialNumber: nil)
          end
        end

        context 'when below root and immediate ancestor is not found' do
          subject(:match) { raymondaspis_eq.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Trilobita')
          end

          it do
            expect(match.taxon).to be_a(Model::Taxon) &
              have_attributes(Name: 'Trilobita',
                              Source: nil,
                              TaxonomicSerialNumber: nil)
          end

          it do
            expect { match }
              .to change(raymondaspis_eq, :missing_ancestors)
              .from(be_empty)
              .to include(an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Styginidae'),
                          an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Corynexochida'))
          end
        end

        context 'when below root and no ancestor is found'
      end

      describe '#parent?' do
        context 'when immediate ancestor is in the database' do
          subject { asaphus_eq.parent? }

          it { is_expected.to be_a described_class }
        end

        context 'when immediate ancestor is not in the database' do
          subject { raymondaspis_eq.parent? }

          it { is_expected.to be_falsey }
        end
      end

      describe '#reference!' do
        subject(:add_reference) { asaphoidea_eq.reference! }

        before { asaphoidea_eq.find }

        it do
          expect { add_reference }
            .to change(asaphoidea_eq, :referenced?)
            .from(be_falsey).to(be_truthy)
        end

        it  do
          expect { add_reference }
            .to change { asaphoidea_eq.taxon.Source }
            .from(be_nil)
            .to('http://webservice.catalogueoflife.org/col/webservice')
            .and change { asaphoidea_eq.taxon.TaxonomicSerialNumber }
            .from(be_nil)
            .to('f3f01b65054a3e887d04554962e49097')
        end
      end

      describe '#referenced?'

      describe '#to_model_attributes'
    end
  end
end
