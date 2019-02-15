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

      describe '#create'

      describe '#find_by_id' do
        context 'when the taxon with concept id exists' do
          subject { asaphida_eq.find_by_id }

          let :be_asaphida do
            be_a(Model::Taxon) & have_attributes(Name: 'Asaphida')
          end

          it { is_expected.to be_asaphida }
        end

        context 'when the taxon with concept id does not exist' do
          subject { asaphoidea_eq.find_by_id }

          it { is_expected.to be_nil }
        end
      end

      describe '#find_by_values' do
        context 'when no parameters are given' do
          subject { asaphoidea_eq.find_by_values }

          it { is_expected.to be_a Model::Taxon }
        end
      end

      describe '#find_parent' do
#         it 'does something' do
#           p asaphus_eq.find_parent
#         end
      end

      describe '#known_ancestors' do
      	context '#when finding by id' do
          subject { asaphoidea_eq.known_ancestors(:find_by_id) }

          let :contain_ancestors do
            contain_exactly(an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Asaphida'))
          end

          it { is_expected.to contain_ancestors }
      	end

      	context '#when finding by id or params' do
          subject { asaphoidea_eq.known_ancestors }

          let :contain_ancestors do
            contain_exactly(an_instance_of(TaxonEquivalent) &
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
      end

      describe '#missing_ancestors' do
      	context '#when finding by id' do
          subject { asaphoidea_eq.missing_ancestors(:find_by_id) }

          let :contain_ancestors do
            contain_exactly(an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Trilobita'),
                            an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Arthropoda'),
                            an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Animalia'))
          end

          it { is_expected.to contain_ancestors }
      	end

      	context '#when finding by id or params' do
          subject { asaphoidea_eq.missing_ancestors }

          let :contain_ancestors do
            contain_exactly(an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Asaphida'),
                            an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Trilobita'),
                            an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Arthropoda'),
                            an_instance_of(TaxonEquivalent) &
                            have_attributes(name: 'Animalia'))
          end

          it { is_expected.to be_empty }
        end
      end
    end
  end
end
