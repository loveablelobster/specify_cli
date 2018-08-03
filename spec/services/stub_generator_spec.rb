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

      let(:det) { { 'Family' => 'Asaphidae' } }
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
                               rank: rank)
      end

      let :county do
        rank = an_instance_of(Model::AdministrativeDivision)
               .and have_attributes(Name: 'County')
        an_instance_of(Model::GeographicName)
          .and have_attributes(Name: 'Douglas County',
                               rank: rank)
      end

      let :disciplines do
        a_collection_including(stub_generator.discipline)
      end

      let :prep_type do
        an_instance_of(Model::PreparationType)
          .and have_attributes Name: 'Specimen'
      end

      describe '.load_yaml(file)' do
        context 'when YAML specifies locality' do
          subject { described_class.load_yaml file }

          let :file do
            Pathname.new(Dir.pwd).join('spec', 'support', 'stub_locality.yaml')
          end

          let :locality do
            have_attributes LocalityName: 'Downtown Lawrence',
                            geographic_name: county
          end

          it { is_expected.to have_attributes accession: accession }

          it { is_expected.to have_attributes cataloger: agent }

          it { is_expected.to have_attributes collecting_geography: county }

          it { is_expected.to have_attributes collecting_locality: locality }

          it { is_expected.to have_attributes taxon: taxon }

          it { is_expected.to have_attributes preparation_type: prep_type }

          it { is_expected.to have_attributes preparation_count: 1 }

          it do
            is_expected
              .to have_attributes dataset_name: 'stubs with locality'
          end
        end

        context 'when YAML does not specify locality' do
          subject { described_class.load_yaml file }

          let :file do
            Pathname.new(Dir.pwd).join('spec', 'support', 'stub.yaml')
          end

          let :locality do
            have_attributes LocalityName: 'default stub locality US',
                            geographic_name: country
          end

          it { is_expected.to have_attributes accession: accession }

          it { is_expected.to have_attributes cataloger: agent }

          it { is_expected.to have_attributes collecting_geography: country }

          it { is_expected.to have_attributes default_locality: locality }

          it { is_expected.to have_attributes taxon: taxon }

          it { is_expected.to have_attributes preparation_type: prep_type }

          it { is_expected.to have_attributes preparation_count: 1 }

          it do
            is_expected
              .to have_attributes dataset_name: 'stubs with default locality'
          end
        end
      end

      describe '#accession' do
        context 'when passed a known accession number' do
          subject(:set_accession) { stub_generator.accession = '2018-AA-001' }

          it do
            expect { set_accession }
              .to change(stub_generator, :accession).from(be_nil).to accession
          end
        end

        context 'when passed an unknown accession number' do
          subject(:set_accession) { stub_generator.accession = 'void' }

          it do
            expect { set_accession }
              .to raise_error ACCESSION_NOT_FOUND_ERROR + 'void'
          end
        end
      end

      describe '#cataloger=(user_name)' do
        context 'when passed a known user name' do
          subject(:set_cataloger) { stub_generator.cataloger = 'specmanager' }

          it do
            expect { set_cataloger }
              .to change(stub_generator, :cataloger)
              .from(stub_generator.agent).to agent
          end
        end

        context 'when passed an unknown user name' do
          subject(:set_cataloger) { stub_generator.cataloger = 'nobody' }

          it do
            expect { set_cataloger }
              .to raise_error USER_NOT_FOUND_ERROR + 'nobody'
          end
        end
      end

      describe '#collecting_data=(vals)' do
        let :locality do
          an_instance_of(Model::Locality)
            .and have_attributes(LocalityName: 'Downtown Lawrence',
                                 geographic_name: county)
        end

        context 'when passed country only' do
          subject(:set_collecting) { stub_generator.collecting_data = cd }

          let(:cd) { { 'Country' => 'United States' } }

          it do
            expect { set_collecting }
              .to change(stub_generator, :collecting_geography)
              .from(be_nil).to country
          end
        end

        context 'when passed country, state, and county' do
          subject(:set_collecting) { stub_generator.collecting_data = cd }

          let :cd do
            { 'Country' => 'United States',
              'State' => 'Kansas',
              'County' => 'Douglas County' }
          end

          it do
            expect { set_collecting }
              .to change(stub_generator, :collecting_geography)
              .from(be_nil).to county
          end
        end

        context 'when passed county only and county is ambiguous' do
          subject(:set_collecting) { stub_generator.collecting_data = cd }

          let(:cd) { { 'County' => 'Douglas County' } }

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
            { 'Country' => 'United States',
              'State' => 'Kansas',
              'County' => 'Douglas County',
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

        context 'when passing an unknown locality' do
          subject(:set_collecting) { stub_generator.collecting_data = cd }

          let(:cd) { { locality: 'No place' } }

          it do
            expect { set_collecting }
              .to raise_error LOCALITY_NOT_FOUND_ERROR + 'No place'
          end
        end

        context 'when passed an unknown geography' do
        	subject(:set_collecting) { stub_generator.collecting_data = cd }

        	let(:cd) do
        	  { 'Country' => 'United States',
        		  'State' => 'British Columbia' }
        	end

        	it do
        		expect { set_collecting }
        		  .to raise_error GEOGRAPHY_NOT_FOUND_ERROR + cd.values.join(', ')
        	end
        end
      end

      describe '#collecting_locality!' do
        subject { stub_generator.collecting_locality! }

        context 'when collecting locality is set' do
          let :cd do
            { 'Country' => 'United States',
              'State' => 'Kansas',
              'County' => 'Douglas County',
              locality: 'Downtown Lawrence' }
          end

          before { stub_generator.collecting_data = cd }

          it do
            is_expected.to be_a(Model::Locality)
              .and have_attributes LocalityName: 'Downtown Lawrence',
                                   geographic_name: county
          end
        end

        context 'when collecting locality is not set but geography is set' do
          before do
            stub_generator.default_locality_name = 'default stub locality US'
            stub_generator.collecting_data = { 'Country' => 'United States' }
          end

          it do
            is_expected.to be_a(Model::Locality)
              .and have_attributes LocalityName: 'default stub locality US',
                                   geographic_name: country
          end
        end

        context 'when collecting locality and geography are not set' do
          it { is_expected.to be_nil }
        end
      end

      describe '#create(count)' do
        let :record_set_items do
          first_item = an_instance_of(Model::RecordSetItem)
                       .and(have_attributes(OrderNumber: 0))
          last_item = an_instance_of(Model::RecordSetItem)
                      .and(have_attributes(OrderNumber: 9))
          a_collection_including(first_item, last_item)
            .and have_attributes count: 10
        end

        let :generated do
          first_collection_object = an_instance_of(Model::CollectionObject)
            .and(have_attributes(CatalogNumber: '000000001'))
          last_collection_object = an_instance_of(Model::CollectionObject)
            .and(have_attributes(CatalogNumber: '000000010'))
          a_collection_including(first_collection_object,
                                 last_collection_object)
            .and have_attributes count: 10
        end

        it do
          expect { stub_generator.create(10) }
            .to change { Model::CollectionObject.dataset.count }.by 10
        end

        it do
          expect { stub_generator.create 1 }
            .to change { Model::CollectionObject.dataset.last }
            .from(be_nil).to having_attributes(cataloger: stub_generator.agent)
        end

        it do
          expect { stub_generator.create 10 }
            .to change(stub_generator, :record_set)
            .from(be_nil)
            .to an_instance_of(Model::RecordSet)
            .and have_attributes record_set_items: record_set_items
        end

        it do
          expect { stub_generator.create 10 }
            .to change(stub_generator, :generated)
            .from(be_nil)
            .to generated
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

        context 'when creating with collecting event with locality' do
          let :cd do
            { 'Country' => 'United States',
              'State' => 'Kansas',
              'County' => 'Douglas County',
              locality: 'Downtown Lawrence' }
          end

          let :collecting_event do
            an_instance_of(Model::CollectingEvent)
              .and have_attributes locality: locality
          end

          let :locality do
            an_instance_of(Model::Locality)
              .and have_attributes(LocalityName: 'Downtown Lawrence',
                                   geographic_name: county)
          end

          before { stub_generator.collecting_data = cd }

          it do
            expect { stub_generator.create 1 }
              .to change { Model::CollectionObject.dataset.last }
              .from(be_nil)
              .to having_attributes(collecting_event: collecting_event)
          end
        end

        context 'when creating with collecting event without locality' do
          let :cd do
            { 'Country' => 'United States',
              'State' => 'Kansas',
              'County' => 'Douglas County' }
          end

          let :collecting_event do
            an_instance_of(Model::CollectingEvent)
              .and have_attributes locality: locality
          end

          let :locality do
            an_instance_of(Model::Locality)
              .and have_attributes(LocalityName: 'default locality',
                                   geographic_name: county)
          end

          before do
            stub_generator.default_locality_name = 'default locality'
            stub_generator.collecting_data = cd
          end

          it do
            expect { stub_generator.create 1 }
              .to change { Model::CollectionObject.dataset.last }
              .from(be_nil)
              .to having_attributes(collecting_event: collecting_event)
          end
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

      describe '#default_locality' do
        subject { stub_generator.default_locality }

        context 'when the default locality is known' do
          before do
            stub_generator.default_locality_name = 'default stub locality'
          end

          it do
            is_expected.to be_a(Model::Locality)
              .and have_attributes LocalityName: 'default stub locality'
          end
        end

        context 'when the default locality is not known' do
          it { is_expected.to be_nil }
        end
      end

      describe '#default_locality!' do
        subject(:get_default) { stub_generator.default_locality! }

        let(:name) { 'not cataloged, see label' }

        context 'when the default locality is known' do
          before do
            stub_generator.default_locality_name = 'default stub locality'
          end

          it do
            is_expected.to be_a(Model::Locality)
              .and have_attributes LocalityName: 'default stub locality'
          end
        end

        context 'when the default locality is not known and'\
                ' collecting_geography is set' do
          let :locality do
            an_instance_of(Model::Locality)
              .and have_attributes LocalityName: 'not cataloged, see label',
                                   geographic_name: country
          end

          before do
            stub_generator.collecting_data = { 'Country' => 'United States' }
          end

          it do
            expect { get_default }
              .to change(stub_generator, :default_locality)
              .from(be_nil)
              .to locality
          end
        end

        context 'when the default locality is not known and'\
                ' collecting_geography is not set' do
          let :locality do
            an_instance_of(Model::Locality)
              .and have_attributes(LocalityName: 'not cataloged, see label',
                                   geographic_name: be_nil)
          end

          it do
            expect { get_default }
              .to change(stub_generator, :default_locality)
              .from(be_nil)
              .to locality
          end
        end
      end

      describe '#determination=(vals)' do
        context 'when passed a known taxon' do
          subject(:set_determination) { stub_generator.determination = det }

          it do
            expect { set_determination }
              .to change(stub_generator, :taxon).from(be_nil).to taxon
          end
        end

        context 'when passed an unknown taxon' do
          subject(:set_determination) { stub_generator.determination = indet }

          let(:indet) { { 'Family' => 'Illaenidae' } }

          it do
            expect { set_determination }
              .to raise_error TAXON_NOT_FOUND_ERROR + '{"Family"=>"Illaenidae"}'
          end
        end
      end

      describe '#find_locality(locality_name)' do
        subject { stub_generator.find_locality 'Downtown Lawrence' }

        it do
          is_expected.to be_a(Model::Locality)
            .and have_attributes(LocalityName: 'Downtown Lawrence',
                                 geographic_name: county)
        end
      end

      describe '#geography' do
        subject { stub_generator.geography }

        it do
          is_expected.to be_a(Model::Geography)
            .and have_attributes disciplines: disciplines
        end
      end

      describe '#localities' do
        subject { stub_generator.localities }

        let :locality do
          an_instance_of(Model::Locality)
            .and have_attributes(LocalityName: 'Downtown Lawrence',
                                 geographic_name: county)
        end

        it do
          is_expected.to be_a(Sequel::Dataset)
            .and include locality
        end
      end

      describe '#preparation=(type:, count:)' do
        context 'when type is known' do
          subject(:set_preparation) { stub_generator.preparation = prep }

          it do
            expect { set_preparation }
              .to change(stub_generator, :preparation_type)
              .from(be_nil).to(prep_type)
              .and change(stub_generator, :preparation_count)
              .from(be_nil).to 1
          end
        end

        context 'when type is unknown' do
          subject(:set_preparation) { stub_generator.preparation = unprep }

          let(:unprep) { { type: 'Thing', count: 1 } }

          it do
            expect { set_preparation }
              .to raise_error PREPTYPE_NOT_FOUND_ERROR + 'Thing'
          end
        end
      end

      describe '#taxonomy' do
        subject { stub_generator.taxonomy }

        it do
          is_expected.to be_a(Model::Taxonomy)
            .and have_attributes disciplines: disciplines
        end
      end
    end
  end
end
