# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe Equivalent do
      let :asaphida_eq do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          external: Factories::CatalogueOfLife::Taxon.with(:asaphida))
      end

      let :asaphoidea_eq do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          external: Factories::CatalogueOfLife::Taxon.with(:asaphoidea))
      end

      let :asaphidae_eq do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          external: Factories::CatalogueOfLife::Taxon.with(:asaphidae))
      end

      let :asaphus_eq do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          external: Factories::CatalogueOfLife::Taxon.with(:asaphus))
      end

      let :asaphus_expansus_eq do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          external: Factories::CatalogueOfLife::Taxon.with(:asaphus_expansus))
      end

      let :raymondaspis_eq do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          external: Factories::CatalogueOfLife::Taxon.with(:raymondaspis))
      end

      let :animalia_eq do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          external: Factories::CatalogueOfLife::Taxon.with(:root))
      end

      describe '#ancestors' do
        context 'when initialized with an external taxon' do
          subject { asaphus_eq.ancestors }

          let :contain_ancestors do
            contain_exactly(an_instance_of(Equivalent) &
                            have_attributes(name: 'Asaphidae'),
                            an_instance_of(Equivalent) &
                            have_attributes(name: 'Asaphoidea'),
                            an_instance_of(Equivalent) &
                            have_attributes(name: 'Asaphida'),
                            an_instance_of(Equivalent) &
                            have_attributes(name: 'Trilobita'),
                            an_instance_of(Equivalent) &
                            have_attributes(name: 'Arthropoda'),
                            an_instance_of(Equivalent) &
                            have_attributes(name: 'Animalia'))
          end

          it { is_expected.to contain_ancestors }
        end

        context 'when initialized with an internal taxon' do
          subject(:trilobita) do
            described_class.new Factories::Model::Taxonomy.for_tests,
                                internal: Specify::Model::Taxon.first(name: 'Trilobita')
          end

          it { p trilobita }
        end
      end

      describe '#id' do
        subject(:ids) { asaphida_eq.id }

        it do
          expect(ids)
            .to have_attributes external: '5ac1330933c62d7d617a8d4a80dcecf3',
                                internal: nil
        end
      end

      describe '#create' do
        context 'if the immediate ancestor is known' do
          subject(:create_a_expansus) { asaphus_expansus_eq.create }

          let :s_source do
            'http://webservice.catalogueoflife.org/col/webservice'
          end

          let :rank_id do
            asaphus_expansus_eq.rank
                               .equivalent(Factories::Model::Taxonomy.for_tests)
                               .RankID
          end

          it do
            expect { create_a_expansus }
              .to change(asaphus_expansus_eq, :internal)
              .from(be_nil)
              .to(an_instance_of(Model::Taxon) &
                  have_attributes(Name: 'expansus',
                                  Source: URL + API_ROUTE,
                                  RankID: rank_id))
          end
        end

        context 'if the immediate ancestor is not known and '\
                'fill-lineage is true' do
          subject(:create_r) { raymondaspis_eq.create(fill_lineage: true) }

          #
        end

        context 'if the immediate ancestor is not known and '\
                'fill-lineage is false' do
          subject(:create_r) { raymondaspis_eq.create }

          it do
            expect { create_r }.to raise_error RuntimeError,
                                                   'Immidiate ancestor missing'
          end
        end
      end

      describe '#external'

      describe '#find' do

      end

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

      describe '#internal'

      describe '#known_ancestor' do
        context 'when root' do
          subject(:root) { animalia_eq.known_ancestor }

          it { is_expected.to be_falsey }
        end

        context 'when below root and immediate ancestor is found by id' do
          subject(:match) { asaphus_expansus_eq.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Asaphus')
          end

          it do
            expect(match.internal).to be_a(Model::Taxon) &
              have_attributes(Name: 'Asaphus',
                              Source: URL + API_ROUTE,
                              TaxonomicSerialNumber: '67b8da25464f297cf'\
                                                     '738a3712bc7eaa0')
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
            expect(match.internal).to be_a(Model::Taxon) &
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
            expect(match.internal).to be_a(Model::Taxon) &
              have_attributes(Name: 'Trilobita',
                              Source: nil,
                              TaxonomicSerialNumber: nil)
          end
        end

        context 'when below root and no ancestor is found'
      end

      describe '#missing_ancestors' do
        subject(:missing) { raymondaspis_eq.missing_ancestors }

        it do
          expect(missing)
            .to include(an_instance_of(Equivalent) &
                          have_attributes(name: 'Styginidae'),
                        an_instance_of(Equivalent) &
                          have_attributes(name: 'Corynexochida'))
        end
      end

      describe '#name'

      describe '#parent_taxon' do
        context 'when immediate ancestor is in the database' do
          subject { asaphus_expansus_eq.parent_taxon }

          it { is_expected.to be_a described_class }
        end

        context 'when immediate ancestor is not in the database' do
          subject { raymondaspis_eq.parent_taxon }

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
            .to change { asaphoidea_eq.internal.Source }
            .from(be_nil)
            .to(URL + API_ROUTE)
            .and change { asaphoidea_eq.internal.TaxonomicSerialNumber }
            .from(be_nil)
            .to('f3f01b65054a3e887d04554962e49097')
        end
      end

      describe '#referenced?'

      describe '#to_model_attributes'
    end
  end
end
