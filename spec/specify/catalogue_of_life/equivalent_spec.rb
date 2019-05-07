# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe Equivalent do
      let :asaphida_ext do
        described_class.new(Factories::Model::Taxonomy.for_tests,
          Factories::CatalogueOfLife::Taxon.with(:asaphida))
      end

      let :asaphida_int do
        described_class.new(Factories::Model::Taxonomy.for_tests,
                            Specify::Model::Taxon.first(name: 'Asaphida'))
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

      let :asaphoidea_int do
        described_class.new(Factories::Model::Taxonomy.for_tests,
                            Specify::Model::Taxon.first(name: 'Asaphoidea'))
      end

      let :trilobita_int do
        described_class.new(Factories::Model::Taxonomy.for_tests,
                            Specify::Model::Taxon.first(name: 'Trilobita'))
      end

      let :life_int do
        described_class.new(Factories::Model::Taxonomy.for_tests,
                            Specify::Model::Taxon.first(name: 'Life'))
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
          subject { asaphida_ext.external }

          it { is_expected.to be_a CatalogueOfLife::Taxon }
        end

        context 'when intitialized with an internal taxon' do
          subject { asaphida_int.external}

          it { is_expected.to be_nil }
        end

        context 'when intitialized with an internal taxon that is found' do
          subject { asaphida_int.external}

          before { asaphida_int.find }

          it { is_expected.to be_a CatalogueOfLife::Taxon }
        end
      end

      describe '#find' do
        context 'when intitialized with an external taxon' do
          subject(:found) { asaphida_ext.find }

          it do
            expect(found).to be_a(Model::Taxon) &
              have_attributes(name: 'Asaphida')
          end
        end

        context 'when intitialized with an internal taxon' do
          subject(:found) { asaphida_int.find}

          it do
            expect(found).to be_a(CatalogueOfLife::Taxon) &
              have_attributes(name: 'Asaphida')
          end
        end

        context 'when intitialized with an external taxon whose internal is'\
                ' not referenced (has no external id)' do
          subject(:found) { asaphoidea_ext.find }

          it do
            expect(found).to be_a(Model::Taxon) &
              have_attributes(name: 'Asaphoidea')
          end
        end

        context 'when intitialized with an internal taxon that is not'\
                ' referenced (has no external id)' do
          subject(:found) { trilobita_int.find }

          it do
            expect(found).to be_a(CatalogueOfLife::Taxon) &
              have_attributes(name: 'Trilobita')
          end
        end
      end

      describe '#find_by_id' do
        context 'when initialized with an external taxon and the equivalent'\
                ' with taxonomic serial number exists' do
          subject(:exact_match) { asaphida_ext.find_by_id }

          let :be_asaphida do
            be_a(Model::Taxon) & have_attributes(name: 'Asaphida')
          end

          it { is_expected.to be_asaphida }

          it do
            expect {exact_match}
              .to change(asaphida_ext, :referenced?)
              .from(be_falsey)
              .to(be_truthy)
          end
        end

        context 'when initialized with an external taxon and the equivalent'\
                ' with taxonomic_serial_number does not exist' do
          subject { asaphoidea_ext.find_by_id }

          it { is_expected.to be_nil }
        end

        context 'when initialized with an internal taxon and the equivalent'\
                ' with taxonomic serial number exists' do
          subject(:exact_match) { asaphida_int.find_by_id }

          let :be_asaphida do
            be_a(CatalogueOfLife::Taxon) & have_attributes(name: 'Asaphida')
          end

          it { is_expected.to be_asaphida }

          it do
            expect {exact_match}
              .to change(asaphida_int, :referenced?)
              .from(be_falsey)
              .to(be_truthy)
          end
        end

        context 'when initialized with an internal taxon and the equivalent'\
                ' with taxonomic_serial_number does not exist' do
          subject { asaphoidea_ext.find_by_id }

          it { is_expected.to be_nil }
        end
      end

      describe '#find_by_values' do
        context 'when initialized with an external taxon, no parent is given,'\
                ' and the equivalent is found' do
          subject(:found) { asaphoidea_ext.find_by_values }

          it do
            expect(found).to be_a(Model::Taxon) &
              have_attributes(name: 'Asaphoidea')
          end

          it do
            expect { found }.to change(asaphoidea_ext, :equivalent)
                            .from(be_nil)
                            .to an_instance_of(Model::Taxon) &
                              have_attributes(name: 'Asaphoidea')
          end
        end

        context 'when initialized with an external taxon, a parent is given,'\
                ' and the equivalent is found' do
          subject(:found) { asaphoidea_ext.find_by_values(asaphida_ext)}

          it do
            expect(found).to be_a(Model::Taxon) &
              have_attributes(name: 'Asaphoidea')
          end

          it do
            expect { found }.to change(asaphoidea_ext, :equivalent)
                            .from(be_nil)
                            .to an_instance_of(Model::Taxon) &
                              have_attributes(name: 'Asaphoidea')
          end
        end

        context 'when initialized with an external taxon and the equivalent'\
                ' is not found' do
          subject { raymondaspis_ext.find_by_values }

          it { is_expected.to be_nil }
        end

        context 'when initialized with an external taxon and multiple matches'\
                ' are found' do
          subject(:found) { asaphida_ext.find_by_values }

          before { Model::Taxon.first(Name: 'Malacostraca')
                               .add_child  Name: 'Asaphida',
                               rank: Factories::Model::Rank.order,
                               IsAccepted: true,
                               IsHybrid: false,
                               RankID: Factories::Model::Rank.order.RankID,
                               taxonomy: Factories::Model::Taxonomy.for_tests} # create 'Asaphida in Malacostraca'

          it do
            expect { found }
              .to raise_error RuntimeError, 'Ambiguous match'
          end
        end

        context 'when initialized with an internal taxon and the equivalent'\
                ' is found' do
          subject(:found) { asaphida_int.find_by_values }

          it do
            expect(found).to be_a(CatalogueOfLife::Taxon) &
              have_attributes(name: 'Asaphida')
          end
        end

        context 'when initialized with an internal taxon and the equivalent'\
                ' is not found' do
          it 'should return nil'
        end

        context 'when initialized with an internal taxan and multiple matches'\
                ' are found' do
          it 'should raise error'
        end
      end

      describe '#id' do
        context 'when initialized with an external taxon and the equivalent'\
                ' is not found' do
          subject(:ids) { asaphida_ext.id }

          it do
            expect(ids)
              .to have_attributes taxon: '5ac1330933c62d7d617a8d4a80dcecf3',
                                  equivalent: nil
          end
        end

        context 'when initialized with an external taxon and the equivalent'\
                ' is found' do
          subject(:ids) { asaphida_ext.id }

          before { asaphida_ext.find }

          it do
            expect(ids)
              .to have_attributes taxon: '5ac1330933c62d7d617a8d4a80dcecf3',
                                  equivalent: '733387fb-dcee-44d6'\
                                              '-a6e0-45166428390b'
          end
        end

        context 'when initialized with an internal taxon and the equivalent'\
                ' is not found' do
          subject(:ids) { asaphida_int.id }

          it do
            expect(ids)
              .to have_attributes taxon: '733387fb-dcee-44d6'\
                                         '-a6e0-45166428390b',
                                  equivalent: nil
          end
        end

        context 'when initialized with an internal taxon and the equivalent'\
                ' is found' do
          subject(:ids) { asaphida_int.id }

          before { asaphida_int.find }

          it do
            expect(ids)
              .to have_attributes taxon: '733387fb-dcee-44d6'\
                                         '-a6e0-45166428390b',
                                  equivalent: '5ac1330933c62d7d617a8d4a80dcecf3'
          end
        end
      end

      describe '#internal' do
        context 'when intitialized with an internal taxon' do
          subject { asaphida_int.internal }

          it { is_expected.to be_a Model::Taxon }
        end

        context 'when intitialized with an external taxon' do
          subject { asaphida_ext.internal}

          it { is_expected.to be_nil }
        end

        context 'when intitialized with an external taxon that is found' do
          subject { asaphida_ext.internal}

          before { asaphida_ext.find }

          it { is_expected.to be_a Model::Taxon }
        end
      end

      describe '#known_ancestor' do
        context 'when initialized with an external taxon which is root' do
          subject(:root) { animalia_ext.known_ancestor }

          it { is_expected.to be_falsey }
        end

        context 'when initialized with an external taxon which is below root'\
                ' and immediate ancestor is found by id' do
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

        context 'when initialized with an external taxon which is below root'\
                ' and immediate ancestor is found by name, rank, parent' do
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

        context 'when initialized with an external taxon which is below root'\
                'and immediate ancestor is not found' do
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

        context 'when initialized with an external taxon which is below root'\
                'and no ancestor is found' do
          it 'should raise error'
                end

        context 'when initialized with an internal taxon which is root' do
          subject(:root) { life_int.known_ancestor }

          it { is_expected.to be_falsey }
        end

        context 'when initialized with an internal taxon which is below root'\
                ' and immediate ancestor is found by id' do
          subject(:match) { asaphoidea_int.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Asaphida')
          end

          it do
            expect(match.equivalent).to be_a(CatalogueOfLife::Taxon) &
              have_attributes(name: 'Asaphida',
                              id: '5ac1330933c62d7d617a8d4a80dcecf3')
          end
        end

        context 'when initialized with an internal taxon which is below root'\
                ' and immediate ancestor is found by name, rank, parent' do
          subject(:match) { asaphida_int.known_ancestor }

          it do
            expect(match).to be_a(described_class) &
              have_attributes(name: 'Trilobita')
          end

          it do
            expect(match.equivalent).to be_a(CatalogueOfLife::Taxon) &
              have_attributes(name: 'Trilobita')
          end
        end

        context 'when initialized with an external taxon which is below root'\
                'and immediate ancestor is not found' do
          it 'should return the last knonw ancestor'
        end

        context 'when initialized with an internal taxon which is below root'\
                'and no ancestor is found' do
          it 'should raise error'
        end
      end

      describe '#lineage' do
        context 'when initialized with an external taxon' do
          subject { asaphus_ext.lineage }

          it { is_expected.to be_a Lineage }
        end

        context 'when initialized with an internal taxon' do
          subject { trilobita_int.lineage }

          it { is_expected.to be_a Lineage }
        end
      end

      describe '#missing_ancestors' do
        context 'when initialized with an external taxon' do
          subject(:missing) { raymondaspis_ext.missing_ancestors }

          it do
            expect(missing)
              .to include(an_instance_of(Equivalent) &
                            have_attributes(name: 'Styginidae'),
                          an_instance_of(Equivalent) &
                            have_attributes(name: 'Corynexochida'))
          end
        end

        context 'when initialized with an internal taxon' do
          it 'should be a list of missing ancestors'
        end
      end

      describe '#mutable?' do
        context 'when initialized with an external taxon' do
          subject { asaphida_ext.mutable? }

          it { is_expected.to be_truthy }
        end

        context 'when initialized with an internal taxon' do
          subject { trilobita_int.mutable? }

          it { is_expected.to be_falsey }
        end
      end

      describe '#name'

      describe '#parent_taxon' do
        context 'when initialized with an external taxon and immediate'\
                ' ancestor is known' do
          subject { asaphus_expansus_ext.parent_taxon }

          it { is_expected.to be_a described_class }
        end

        context 'when initialized with an external taxon and immediate'\
                'ancestor is not known' do
          subject { raymondaspis_ext.parent_taxon }

          it { is_expected.to be_falsey }
        end

        context 'when initialized with an internal taxon and immediate'\
                ' ancestor is known' do
          subject { asaphoidea_int.parent_taxon }

          it { is_expected.to be_a(described_class) & have_attributes(name: 'Asaphida')}
        end

        context 'when initialized with an internal taxon and immediate'\
                'ancestor is not known' do

          it 'should return false'
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
