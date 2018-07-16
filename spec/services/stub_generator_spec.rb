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

      let :country do
        rank = an_instance_of(Model::AdministrativeDivision)
               .and have_attributes(Name: 'Country')
        an_instance_of(Model::GeographicName)
          .and have_attributes(Name: 'United States',
                               administrative_division: rank)
      end

      let :county do
        rank = an_instance_of(Model::AdministrativeDivision)
               .and have_attributes(Name: 'County')
        an_instance_of(Model::GeographicName)
          .and have_attributes(Name: 'Douglas County',
                               administrative_division: rank)
      end

      describe '#accession' do
        subject(:set_accession) { stub_generator.accession = '2018-AA-001' }

        it do
          expect { set_accession }
            .to change(stub_generator, :accession).from(be_nil).to accession
        end
      end

      describe '#collecting_data=(higher_geography:, locality:)' do
        let :locality do
        	an_instance_of(Model::Locality)
        	  .and have_attributes(LocalityName: 'Downtown Lawrence',
        	                       geographic_name: county)
        end

        context 'when passed country only' do
        	subject(:set_collecting) { stub_generator.collecting_data = cd }

          let :cd do
            { higher_geography: { 'Country' => 'United States' } }
          end

          it do
          	expect { set_collecting }
          	  .to change(stub_generator, :collecting_geography)
          	  .from(be_nil).to country
          end
        end

        context 'when passed country, state, and county' do
        	subject(:set_collecting) { stub_generator.collecting_data = cd }

        	let :cd do
        	  { higher_geography: { 'Country' => 'United States',
                                  'State' => 'Kansas',
                                  'County' => 'Douglas County' } }
        	end

        	it do
        		expect { set_collecting }
        		  .to change(stub_generator, :collecting_geography)
        		  .from(be_nil).to county
        	end
        end

        context 'when passed county only and county is ambiguous' do
        	subject(:set_collecting) { stub_generator.collecting_data = cd }

        	let :cd do
        	  { higher_geography: { 'County' => 'Douglas County' } }
        	end

        	it do
        		expect { set_collecting }
        		  .to raise_error Model::TreeQueryable::AMBIGUOUS_MATCH_ERROR +
        		                  ' for Douglas County: ["United States, Kansas,'\
        		                  ' Douglas County", "United States, Wisconsin,'\
        		                  ' Douglas County"]'
        	end
        end

        context 'when passed geography and locality' do
        	subject(:set_collecting) { stub_generator.collecting_data = cd }

        	let :cd do
        	  { higher_geography: { 'Country' => 'United States',
                                  'State' => 'Kansas',
                                  'County' => 'Douglas County' },
              locality: 'Downtown Lawrence' }
        	end

          it do
          	expect { set_collecting }
              .to change(stub_generator, :collecting_geography)
        		  .from(be_nil).to(county)
          	  .and change(stub_generator, :collecting_locality)
          	  .from(be_nil).to(locality)
          end
        end

        context 'when passed locality only' do
          subject(:set_collecting) { stub_generator.collecting_data = cd }

          let(:cd) { { locality: 'Downtown Lawrence' } }

          it do
          	expect { set_collecting }
          	  .to change(stub_generator, :collecting_locality)
          	  .from(be_nil).to locality
          end
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

        context 'when creating with collecting events' do
          it 'adds locality information to the collecting event'
        end

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
