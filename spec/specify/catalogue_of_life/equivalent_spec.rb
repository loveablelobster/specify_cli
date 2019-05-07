# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe Equivalent do
      let :asaphida_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:asaphida))
      end

      let :asaphoidea_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:asaphoidea))
      end

      let :asaphidae_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:asaphidae))
      end

      let :asaphus_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:asaphus))
      end

      let :asaphus_expansus_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:asaphus_expansus))
      end

      let :raymondaspis_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:raymondaspis))
      end

      let :animalia_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:root))
      end

      let :trilobita_int do
        described_class.new(Factories::Model::Taxonomy.for_tests,
                            Specify::Model::Taxon.first(name: 'Trilobita'))
      end

      describe '#ancestors' do
        context 'when initialized with an external taxon' do
          subject { asaphus_ext.ancestors }

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
            trilobita_int.ancestors
          end

          let :contain_ancestors do
            include(an_instance_of(Equivalent) &
                      have_attributes(name: 'Arthropoda'),
                      an_instance_of(Equivalent) &
                      have_attributes(name: 'Animalia'),
                      an_instance_of(Equivalent) &
                      have_attributes(name: 'Life'))
          end

          it { is_expected.to contain_ancestors }
        end
      end

      describe '#can_mutate?' do
        context 'when initialized with an external taxon' do
          subject { asaphida_ext.can_mutate? }

          it { is_expected.to be_truthy }
        end

        context 'when initialized with an internal taxon' do
          subject { trilobita_int.can_mutate? }

          it { is_expected.to be_falsey }
        end
      end

      describe '#create' do
        context 'if it is initialized with a database taxon' do
          subject(:create_trilobita) { trilobita_int.create }

          it do
            expect { create_trilobita }
              .to raise_error RuntimeError, 'can\'t mutate Catalogue of life'
          end
        end

        context 'if the immediate ancestor is known' do
          subject(:create_a_expansus) { asaphus_expansus_ext.create }

          let(:species) { Factories::Model::Rank.species }

          it do
            expect { create_a_expansus }
              .to change(asaphus_expansus_ext, :equivalent)
              .from(be_nil)
              .to(an_instance_of(Model::Taxon) &
                  have_attributes(Name: 'expansus',
                                  Source: URL + API_ROUTE,
                                  RankID: species.RankID))
          end
        end

        context 'if the immediate ancestor is not known and '\
                'fill-lineage is true' do
          subject(:create_r) { raymondaspis_ext.create(fill_lineage: true) }

          let(:genus) { Factories::Model::Rank.genus }

          it do
            expect { create_r }
              .to change(raymondaspis_ext, :equivalent)
              .from(be_nil)
              .to(an_instance_of(Model::Taxon) &
                  have_attributes(Name: 'Raymondaspis',
                                  Source: URL + API_ROUTE,
                                  RankID: genus.RankID))
          end
        end

        context 'if the immediate ancestor is not known and '\
                'fill-lineage is false' do
          subject(:create_r) { raymondaspis_ext.create }

          it do
            expect { create_r }.to raise_error RuntimeError,
                                               'Immidiate ancestor missing'
          end
        end
      end

      describe '#external' do
        context 'when intitialized with an external taxon' do

        end

        context 'when intitialized with an internal taxon' do

        end
      end

      describe '#find' do

      end

      describe '#find_by_id' do
        context 'when the taxon with concept id exists' do
          subject(:exact_match) { asaphida_ext.find_by_id }

          let :be_asaphida do
            be_a(Model::Taxon) & have_attributes(Name: 'Asaphida')
          end

          it { is_expected.to be_asaphida }

          it do
            expect {exact_match}
              .to change(asaphida_ext, :referenced?)
              .from(be_falsey)
              .to(be_truthy)
          end
        end

        context 'when the taxon with concept id does not exist' do
          subject { asaphoidea_ext.find_by_id }

          it { is_expected.to be_nil }
        end
      end

      describe '#find_by_values' do
        context 'when no parent is given and the taxon is found' do
          subject(:find_asaphoidea) { asaphoidea_ext.find_by_values }

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

      describe '#id' do
        subject(:ids) { asaphida_ext.id }

        it do
          expect(ids)
            .to have_attributes taxon: '5ac1330933c62d7d617a8d4a80dcecf3',
                                equivalent: nil
        end
      end

      describe '#internal'

      describe '#known_ancestor' do
        context 'when root' do
          subject(:root) { animalia_ext.known_ancestor }

          it { is_expected.to be_falsey }
        end

        context 'when below root and immediate ancestor is found by id' do
          subject(:match) { asaphus_expansus_ext.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Asaphus')
          end

          it do
            expect(match.equivalent).to be_a(Model::Taxon) &
              have_attributes(Name: 'Asaphus',
                              Source: URL + API_ROUTE,
                              TaxonomicSerialNumber: '67b8da25464f297cf'\
                                                     '738a3712bc7eaa0')
          end
        end

        context 'when below root and immediate ancestor is found by'\
                ' name, rank, parent' do
          subject(:match) { asaphidae_ext.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Asaphoidea')
          end

          it do
            expect(match.equivalent).to be_a(Model::Taxon) &
              have_attributes(Name: 'Asaphoidea',
                              Source: nil,
                              TaxonomicSerialNumber: nil)
          end
        end

        context 'when below root and immediate ancestor is not found' do
          subject(:match) { raymondaspis_ext.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Trilobita')
          end

          it do
            expect(match.equivalent).to be_a(Model::Taxon) &
              have_attributes(Name: 'Trilobita',
                              Source: nil,
                              TaxonomicSerialNumber: nil)
          end
        end

        context 'when below root and no ancestor is found'
      end

      describe '#lineage' do
        context 'when initialized with an external taxon' do
          subject { asaphus_ext.lineage }

          it { is_expected.to be_a Lineage}
        end

        context 'when initialized with an internal taxon' do
          subject(:trilobita) do
            described_class.new Factories::Model::Taxonomy.for_tests,
                                Specify::Model::Taxon.first(name: 'Trilobita')
          end

          it { }
        end
      end

      describe '#missing_ancestors' do
        subject(:missing) { raymondaspis_ext.missing_ancestors }

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
          subject { asaphus_expansus_ext.parent_taxon }

          it { is_expected.to be_a described_class }
        end

        context 'when immediate ancestor is not in the database' do
          subject { raymondaspis_ext.parent_taxon }

          it { is_expected.to be_falsey }
        end
      end

      describe '#reference!' do
        subject(:add_reference) { asaphoidea_ext.reference! }

        before { asaphoidea_ext.find }

        it do
          expect { add_reference }
            .to change(asaphoidea_ext, :referenced?)
            .from(be_falsey).to(be_truthy)
        end

        it  do
          expect { add_reference }
            .to change { asaphoidea_ext.equivalent.source }
            .from(be_nil)
            .to(URL + API_ROUTE)
            .and change { asaphoidea_ext.equivalent.taxonomic_serial_number }
            .from(be_nil)
            .to('f3f01b65054a3e887d04554962e49097')
        end
      end

      describe '#referenced?'

      describe '#to_model_attributes'
    end
  end
end
