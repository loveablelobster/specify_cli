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

      describe '#accession' do
        subject(:set_accession) { stub_generator.accession = '2018-AA-001' }

        it do
        	expect { set_accession }
        	  .to change { stub_generator.accession }
        	  .from(be_nil)
        	  .to an_instance_of(Model::Accession)
        	  .and(have_attributes(AccessionNumber: '2018-AA-001'))
        end
      end

      describe '#create(count)' do
      	let :full_generator do
      	  file = Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
          described_class.new(host: 'localhost',
                            database: 'SPSPEC',
                            collection: 'Test Collection',
                            config: file) do |stubs|
            stubs.cataloger = 'specmanager'
            stubs.preparation = { type: 'Specimen', count: 1 }
            stubs.accession = '2018-AA-001'
          end
      	end

      	it do
      	  expect { full_generator.create 10 }
      	    .to change { Model::CollectionObject.dataset.count }
      	end
      end

      describe '#cataloger=(user_name)' do
      	subject(:set_cataloger) { stub_generator.cataloger = 'specmanager' }

      	it do
      		expect { set_cataloger }
      		  .to change { stub_generator.cataloger }
      		  .from(stub_generator.agent)
      		  .to an_instance_of(Model::Agent)
      		  .and(having_attributes(LastName: 'Specman'))
      	end
      end

      describe '#preparation=(type:, count:)' do
        subject(:set_preparation) { stub_generator.preparation = prep }

        let(:prep) { { type: 'Specimen', count: 10 } }

        it do
        	expect { set_preparation }
        	  .to change { stub_generator.preparation_type }
        	  .from(be_nil)
        	  .to(an_instance_of Model::PreparationType)
        	  .and change { stub_generator.preparation_count }
        	  .from(be_nil)
        	  .to 10
        end
      end
    end
  end
end
