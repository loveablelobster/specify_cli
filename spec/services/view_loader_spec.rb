# frozen_string_literal: true

# Tests for the
module Specify
  module Service
    RSpec.describe ViewLoader do
      let :config do
        Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      let(:path) { 'sp_resource' }

      describe '.from_branch(name, config)' do
        context 'when branch is discipline level' do
          subject do
            bname = 'SPSPEC/TestCollection/discipline'
            described_class.from_branch(path: path,
                                        name: bname,
                                        config: config).target
          end

          it do
            is_expected
              .to be_a(Model::Discipline)
              .and have_attributes Name: 'Test Discipline'
          end
        end

        context 'when branch is collection level' do
          subject do
            bname = 'SPSPEC/TestCollection/collection'
            described_class.from_branch(path: path,
                                        name: bname,
                                        config: config).target
          end

          it do
            is_expected
              .to be_a(Model::Collection)
              .and have_attributes CollectionName: 'Test Collection'
          end
        end

        context 'when branch is user type level' do
          subject do
            bname = 'SPSPEC/TestCollection/Manager'
            described_class.from_branch(path: path,
                                        name: bname,
                                        config: config).target
          end

          it do
            is_expected
              .to be_a(UserType)
              .and have_attributes name: :manager
          end
        end

        context 'when branch is user level' do
          subject do
            bname = 'SPSPEC/TestCollection/user/specuser'
            described_class.from_branch(path: path,
                                        name: bname,
                                        config: config).target
          end

          it do
            is_expected
              .to be_a(Model::User)
              .and have_attributes EMail: 'john.doe@example.com',
                                   Name: 'specuser'
          end
        end
      end

      describe '.user_target(hash)' do
        subject { described_class.user_target(user: 'specuser') }

        it do
          is_expected.to be_a(Model::User)
            .and have_attributes Name: 'specuser'
        end
      end

      describe '.user_type_target(hash)' do
        subject { described_class.user_type_target(user_type: 'manager') }

        it do
          is_expected.to be_a(UserType)
            .and have_attributes name: 'manager'
        end
      end

      describe '#target=(level)' do
        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        context 'when level is :discipline' do
          it do
            expect { view_loader.target = :discipline }
              .to change(view_loader, :target)
              .from(be_nil)
              .to a_kind_of(Model::Discipline)
              .and have_attributes Name: 'Test Discipline'
          end
        end

        context 'when level is :collection' do
          it do
            expect { view_loader.target = :collection }
              .to change(view_loader, :target)
              .from(be_nil)
              .to a_kind_of(Model::Collection)
              .and have_attributes CollectionName: 'Test Collection'
          end
        end

        context 'when level is { user_type: :manager }' do
          it do
            expect { view_loader.target = { user_type: 'manager' } }
              .to change(view_loader, :target)
              .from(be_nil)
              .to a_kind_of(UserType)
              .and have_attributes name: 'manager'
          end
        end

        context 'when level is { user: \'specuser\' }' do
          it do
            expect { view_loader.target = { user: 'specuser' } }
              .to change(view_loader, :target)
              .from(be_nil)
              .to a_kind_of(Model::User)
              .and have_attributes EMail: 'john.doe@example.com',
                                   Name: 'specuser'
          end
        end

        context 'when level is nil' do
          it do
            expect { view_loader.target = nil }
              .not_to change(view_loader, :target)
          end
        end
      end

      describe '#import(file)' do
        let :file do
          Pathname.new(Dir.pwd).join('spec', 'support',
                                     'viewsets', 'paleo.views.xml')
        end

        context 'when the app_resource_dir exists' do
          let :view_loader do
            described_class.new host: 'localhost',
                                database: 'SPSPEC',
                                collection: 'Test Collection',
                                level: :collection,
                                config: config
          end

          context 'when file is not a .views.xml file' do
            let :wrong_file do
              Pathname.new(Dir.pwd).join('spec', 'support',
                                     'viewsets', 'paleo.xml')
            end

            it do
              expect { view_loader.import(wrong_file) }
                .to raise_error ArgumentError, FileError::VIEWS_FILE
            end
          end

          context 'when file does not exist' do
            it do
              expect { view_loader.import('no_file.xml') }
                .to raise_error ArgumentError, FileError::NO_FILE
            end
          end

          context 'when file is a .views.xml file' do
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

        context 'when the app_resource_dir does not exist' do
          let :view_loader do
            described_class.new host: 'localhost',
                                database: 'SPSPEC',
                                collection: 'Another Collection',
                                config: config
          end

          context 'when uploading to the collection' do
            before { view_loader.target = :collection }

            it do
              expect { view_loader.import(file) }
                .to change { view_loader.target.view_set }
                .from(nil).to(an_instance_of(Model::ViewSetObject))
                .and change { view_loader.target.view_set&.app_resource_data&.data }
                .from(nil).to(Sequel.blob(File.read(file)))
            end
          end

          context 'when uploading to the user type' do
            before { view_loader.target = { user_type: 'manager' } }

            let(:collection) { Model::Collection.first(Code: 'NECE') }

            it do
              expect { view_loader.import(file) }
                .to change { view_loader.target.view_set(collection) }
                .from(nil).to(an_instance_of(Model::ViewSetObject))
                .and change { view_loader.target.view_set(collection)&.app_resource_data&.data }
                .from(nil).to(Sequel.blob(File.read(file)))
            end
          end
        end
      end

      describe '#view_collection' do
        subject { view_loader.view_collection }

        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        context 'when level is not discipline' do
          before { view_loader.target = :collection }

          it do
            is_expected.to be view_loader.session.collection
          end
        end

        context 'when level is discipline' do
          before { view_loader.target = :discipline }

          it do
            is_expected.to be_nil
          end
        end
      end

      describe '#view_discipline' do
        subject { view_loader.view_discipline }

        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        it do
          is_expected.to be_a(Model::Discipline)
            .and have_attributes Name: 'Test Discipline'
        end
      end

      describe '#personal?' do
        subject { view_loader.personal? }

        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        context 'when discipline level' do
          before { view_loader.target = :discipline }

          it { is_expected.to be_falsey }
        end

        context 'when collection level' do
          before { view_loader.target = :collection }

          it { is_expected.to be_falsey }
        end

        context 'when user type level' do
          before { view_loader.target = { user_type: 'manager' } }

          it { is_expected.to be_falsey }
        end

        context 'when user level' do
          before { view_loader.target = { user: 'specguest' } }

          it { is_expected.to be_truthy }
        end
      end

      describe '#view_level' do
        subject { view_loader.view_level }

        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        context 'when discipline level' do
          before { view_loader.target = :discipline }

          it { is_expected.to be 0 }
        end

        context 'when collection level' do
          before { view_loader.target = :collection }

          it { is_expected.to be 2 }
        end

        context 'when user type level' do
          before { view_loader.target = { user_type: 'manager' } }

          it { is_expected.to be 0 }
        end

        context 'when user level' do
          before { view_loader.target = { user: 'specuser' } }

          it { is_expected.to be 0 }
        end
      end

      describe '#view_type' do
        subject { view_loader.view_type }

        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        it { is_expected.to eq 'Test Discipline' }
      end

      describe '#view_user' do
        subject { view_loader.view_user }

        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        context 'when discipline level' do
          before { view_loader.target = :discipline }

          it { is_expected.to be view_loader.session.user }
        end

        context 'when collection level' do
          before { view_loader.target = :collection }

          it { is_expected.to be view_loader.session.user }
        end

        context 'when user type level' do
          before { view_loader.target = { user_type: 'manager' } }

          it { is_expected.to be view_loader.session.user }
        end

        context 'when user level' do
          before { view_loader.target = { user: 'specguest' } }

          it do
            is_expected.to be_a(Model::User)
              .and have_attributes Name: 'specguest'
          end
        end
      end

      describe '#view_user_type' do
        subject { view_loader.view_user_type }

        let :view_loader do
          described_class.new host: 'localhost',
                              database: 'SPSPEC',
                              collection: 'Test Collection',
                              config: config
        end

        context 'when discipline level' do
          before { view_loader.target = :discipline }

          it { is_expected.to be_nil }
        end

        context 'when collection level' do
          before { view_loader.target = :collection }

          it { is_expected.to be_nil }
        end

        context 'when user type level' do
          before { view_loader.target = { user_type: 'manager' } }

          it { is_expected.to eq 'manager' }
        end

        context 'when user level' do
          before { view_loader.target = { user: 'specguest' } }

          it { is_expected.to eq 'guest' }
        end
      end
    end
  end
end
