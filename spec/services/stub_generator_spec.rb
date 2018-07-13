# frozen_string_literal: true

# Tests for the
module Specify
  module Service
    RSpec.describe StubGenerator do
      let :stub_generator do
        file = Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
        described_class.new host: 'localhost',
                            database: 'SPSPEC',
                            collection: 'Test Collection',
                            config: file
      end

      let(:det) { { taxon: 'Asaphidae', rank: 'Family' } }
      let(:prep) { { type: 'Specimen', count: 1 } }

      let :accession do
      	an_instance_of(Model::Accession)
            .and have_attributes(AccessionNumber: '2018-AA-001')
      end

      let :agent do
        an_instance_of(Model::Agent) & having_attributes(LastName: 'Specman')
      end

      let :taxon do
        rank = an_instance_of(Model::Rank) & have_attributes(Name: 'Family')
        an_instance_of(Model::Taxon) & have_attributes(Name: 'Asaphidae',
                                                       rank: rank)
      end

      describe '#accession' do
        subject(:set_accession) { stub_generator.accession = '2018-AA-001' }

        it do
          expect { set_accession }
            .to change(stub_generator, :accession).from(be_nil).to accession
        end
      end

      describe '#create(count)' do
        it do
          expect { stub_generator.create(10) }
            .to change { Model::CollectionObject.dataset.count }.by 10
        end

        it do
          expect { stub_generator.create 1 }
            .to change { Model::CollectionObject.dataset.last }
            .from(be_nil).to having_attributes(cataloger: stub_generator.agent)
        end

        context 'when creating with an accession' do
          before { stub_generator.accession = '2018-AA-001' }

          it do
          	expect { stub_generator.create 1 }
          	  .to change { Model::CollectionObject.dataset.last }
          	  .from(be_nil).to having_attributes(accession: accession)
          end
        end

        context 'when creating with another cataloger' do
          before { stub_generator.cataloger = 'specmanager' }

          it do
            expect { stub_generator.create 1 }
              .to change { Model::CollectionObject.dataset.last }
              .from(be_nil)
              .to having_attributes(cataloger: agent)
          end
        end

        context 'when creating with determinations' do
          before { stub_generator.determination = det }

          let :determinations do
            a_collection_including an_instance_of(Model::Determination)
              .and have_attributes(taxon: taxon)
          end

          it do
            expect { stub_generator.create 1 }
              .to change { Model::CollectionObject.dataset.last }
              .from(be_nil)
              .to having_attributes(determinations: determinations)
          end
        end

        context 'when creating with collecting events'

        context 'when creating with preparations' do
          before { stub_generator.preparation = prep }

          let :preparations do
            preptype = an_instance_of(Model::PreparationType)
                       .and have_attributes(Name: 'Specimen')
            a_collection_including an_instance_of(Model::Preparation)
              .and have_attributes(CountAmt: 1,
                                   preparation_type: preptype)
          end

          it do
            expect { stub_generator.create 1 }
              .to change { Model::CollectionObject.dataset.last }
              .from(be_nil)
              .to having_attributes(preparations: preparations)
          end
        end
      end

      describe '#cataloger=(user_name)' do
        subject(:set_cataloger) { stub_generator.cataloger = 'specmanager' }

        it do
          expect { set_cataloger }
            .to change(stub_generator, :cataloger)
            .from(stub_generator.agent).to agent
        end
      end

      describe '#determination=(taxon:, rank:)' do
        subject(:set_determination) { stub_generator.determination = det }

        it do
          expect { set_determination }
            .to change(stub_generator, :taxon).from(be_nil).to taxon
        end
      end

      describe '#preparation=(type:, count:)' do
        subject(:set_preparation) { stub_generator.preparation = prep }

        it do
          expect { set_preparation }
            .to change(stub_generator, :preparation_type)
            .from(be_nil).to(an_instance_of(Model::PreparationType))
            .and change(stub_generator, :preparation_count)
            .from(be_nil).to 1
        end
      end
    end
  end
end
