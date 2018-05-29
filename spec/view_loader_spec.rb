# frozen_string_literal: true

# Tests for the
module SpResource
  RSpec.describe ViewLoader do
    def config
      Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
    end

    let :collection_level do
      described_class.from_branch 'SPSPEC/TestCollection/collection',
                                  config: config
    end

    let :discipline_level do
      described_class.from_branch 'SPSPEC/TestCollection/discipline',
                                  config: config
    end

    let :user_type_level do
      described_class.from_branch 'SPSPEC/TestCollection/Manager',
                                  config: config
    end

    let :user_level do
      described_class.from_branch 'SPSPEC/TestCollection/user/specuser',
                                  config: config
    end

    context 'when creating instances from branch names' do
      it 'creates an instance for the discipline level' do
        expect(collection_level.target).to be_a Specify::Model::Collection
      end

      it 'creates an instance for the collection level' do
        expect(discipline_level.target).to be_a Specify::Model::Discipline
      end

      it 'creates an instance for the user type level' do
        expect(user_type_level.target).to be_a UserType
      end

      it 'creates an instance for the user level' do
        expect(user_level.target).to be_a Specify::Model::User
      end
    end

    context 'when uploading a file' do
      let :file do
        Pathname.new(Dir.pwd).join('spec', 'support',
                                   'viewsets', 'paleo.views.xml')
      end

      it 'raises an error if the file is not a .views.xml file' do
        expect { collection_level.import('resource.xml') }
          .to raise_error ArgumentError, FileError::VIEWS_FILE
      end

      it 'imports a views file for the target' do
        dd = collection_level.target.view_set.app_resource_data
        dd.data = nil
        dd.save
      	expect { collection_level.import(file) }
      	  .to change { collection_level.target.view_set.app_resource_data.data }
      	  .from(nil).to(Sequel.blob(File.read(file)))
      end
    end
  end
end
