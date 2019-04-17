# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonLineage do
      let :complete_lineage do
        response = Factories::CatalogueOfLife::TaxonResponse
          .with :asaphus_expansus
        described_class.new(response.classification,
          Factories::Model::Taxonomy.for_tests)
      end

      let :partial_lineage do
        response = Factories::CatalogueOfLife::TaxonResponse
          .with :raymondaspis
        described_class.new(response.classification,
          Factories::Model::Taxonomy.for_tests)
      end

      let :empty_lineage do
        # a taxon where no ancestor is known in the database
      end

      describe '#classification' do
        subject { partial_lineage.classification }

        let :expected_classification do
          [an_object_having_attributes(name: 'Animalia'),
           an_object_having_attributes(name: 'Arthropoda'),
           an_object_having_attributes(name: 'Trilobita'),
           an_object_having_attributes(name: 'Corynexochida'),
           an_object_having_attributes(name: 'Styginidae')]
        end

        it { is_expected.to include an_instance_of TaxonEquivalent }
        it { is_expected.to match_array expected_classification }
      end

      describe '#create' do
        subject(:create_lineage) { partial_lineage.create }

        it do
          expect(create_lineage)
            .to contain_exactly(an_instance_of(Model::Taxon) &
                                have_attributes(Name: 'Corynexochida'),
                                an_instance_of(Model::Taxon) &
                                have_attributes(Name: 'Styginidae'))
        end

        it do
          expect { create_lineage }
            .to change(partial_lineage, :missing_ancestors)
            .from(including(an_object_having_attributes(name: 'Corynexochida'),
                            an_object_having_attributes(name: 'Styginidae')))
            .to(be_empty)
        end
      end

      describe "#known_ancestor" do
        context 'when there is an ancestor in the database' do
          subject(:find_last_ancestor) { partial_lineage.known_ancestor }

          it { expect(find_last_ancestor).to have_attributes name: 'Trilobita' }
        end

        context 'when there is no ancestor in the database' do
          it 'is expected to be nil'
        end
      end

      describe '#missing_ancestors' do
        context 'when there is an ancestor, but intermediates are missing' do
          subject { partial_lineage.missing_ancestors }

          let :expected_missing do
            [an_object_having_attributes(name: 'Corynexochida'),
             an_object_having_attributes(name: 'Styginidae')]
          end

          it { is_expected.to match_array expected_missing }
        end

        context 'when there is an ancestor, and it is the direct ancestor' do
          subject { complete_lineage.missing_ancestors }

          it { is_expected.to be_empty }
        end

        context 'when there is no ancestor' do
          it 'should return the entire lineage'
        end
      end
    end
  end
end
