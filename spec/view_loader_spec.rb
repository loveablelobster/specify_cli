# frozen_string_literal: true

# Tests for the
module Specify
  RSpec.describe ViewLoader do
    let :config do
      Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
    end

    describe '.from_branch(name, config)' do
    	context 'when branch is discipline level' do
        subject do
          bname = 'sp_resource/SPSPEC/TestCollection/discipline'
          described_class.from_branch(bname, config: config).target
        end

        it do
          expect(subject)
            .to be_a(Model::Discipline)
            .and have_attributes Name: 'Test Discipline'
        end
    	end

    	context 'when branch is collection level' do
        subject do
          bname = 'sp_resource/SPSPEC/TestCollection/collection'
          described_class.from_branch(bname, config: config).target
        end

        it do
          expect(subject)
            .to be_a(Model::Collection)
            .and have_attributes CollectionName: 'Test Collection'
        end
    	end

    	context 'when branch is user type level' do
        subject do
          bname = 'sp_resource/SPSPEC/TestCollection/Manager'
          described_class.from_branch(bname, config: config).target
        end

        it do
          expect(subject)
            .to be_a(UserType)
            .and have_attributes name: :manager
        end
    	end

    	context 'when branch is user level' do
        subject do
          bname = 'sp_resource/SPSPEC/TestCollection/user/specuser'
          described_class.from_branch(bname, config: config).target
        end

        it do
          expect(subject)
            .to be_a(Model::User)
            .and have_attributes EMail: 'john.doe@example.com',
                                 Name: 'specuser'
        end
    	end
    end

    describe 'target=(level)' do
    	let :view_loader do
    		described_class.new host: 'localhost',
    		                    database: 'SPSPEC',
    		                    collection: 'Test Collection',
    		                    config: config
    	end

      context 'when level is :discipline' do
        it do
          expect { view_loader.target = :discipline }
            .to change { view_loader.target }
            .from(be_nil)
            .to a_kind_of(Model::Discipline)
            .and have_attributes Name: 'Test Discipline'
        end
      end

      context 'when level is :collection' do
        it do
          expect { view_loader.target = :collection }
            .to change { view_loader.target }
            .from(be_nil)
            .to a_kind_of(Model::Collection)
            .and have_attributes CollectionName: 'Test Collection'
        end
      end

      context 'when level is { user_type: :manager }' do
        it do
          expect { view_loader.target = { user_type: :manager } }
            .to change { view_loader.target }
            .from(be_nil)
            .to a_kind_of(UserType)
            .and have_attributes name: :manager
        end
      end

      context 'when level is { user: \'specuser\' }' do
        it do
          expect { view_loader.target = { user: 'specuser' } }
            .to change { view_loader.target }
            .from(be_nil)
            .to a_kind_of(Model::User)
            .and have_attributes EMail: 'john.doe@example.com',
                                 Name: 'specuser'
        end
      end

      context 'when level is nil' do
      	it do
      		expect { view_loader.target = nil }
      		  .not_to change { view_loader.target }
      	end
      end
    end

    describe 'import(file)' do
    	let :view_loader do
    		described_class.new host: 'localhost',
    		                    database: 'SPSPEC',
    		                    collection: 'Test Collection',
    		                    level: :collection,
    		                    config: config
    	end

      context 'when file is not a .views.xml file' do
        it do
        	expect { view_loader.import('resource.xml') }
            .to raise_error ArgumentError, FileError::VIEWS_FILE
        end
      end

      context 'when file is a .views.xml file' do
        let :file do
          Pathname.new(Dir.pwd).join('spec', 'support',
                                     'viewsets', 'paleo.views.xml')
        end

        before do
          datadir = view_loader.target.view_set.app_resource_data
          datadir.data = nil
          datadir.save
        end

        it do
          expect { view_loader.import(file) }
            .to change { view_loader.target.view_set.app_resource_data.data }
            .from(nil).to(Sequel.blob(File.read(file)))
        end
      end
    end
  end
end
