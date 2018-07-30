# frozen_string_literal: true

# Tests for the
module Specify
  module Configuration
    RSpec.describe Config do
      subject { described_class.new file }

      let(:config) { described_class.empty }

      let :file do
        Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      let :file_dir_names do
        a_hash_including('sp_resource' => 'localhost')
      end

      let :file_hosts do
        db_user = a_hash_including name: 'specmaster',
                                   password: 'masterpass'
        spspec = a_hash_including db_user: db_user,
                                  sp_user: 'specuser'
        databases = a_hash_including 'SPSPEC' => spspec
        localhost = a_hash_including port: 3306,
                                     databases: databases
        hosts = a_hash_including 'localhost' => localhost
      end

      let :hosts do
        a_hash_including 'localhost' => a_hash_including(port: 3600)
      end

      it do
        is_expected.to have_attributes dir_names: file_dir_names,
                                       hosts: file_hosts
      end

      describe '.empty' do
        subject { described_class.empty }

        let :params do
          a_hash_including dir_names: an_instance_of(Hash).and(be_empty),
                           hosts: an_instance_of(Hash).and(be_empty)
        end

        it { is_expected.to have_attributes params: params }

        context 'when given block mapping dir_names' do
          subject do
            described_class.empty do |config|
              config.map_host 'localhost', directory: 'specify_dir'
            end
          end

          let :dir_names do
            a_hash_including 'specify_dir' => 'localhost'
          end

          it { is_expected.to have_attributes dir_names: dir_names }
        end

        context 'when given block adding hosts' do
          subject do
            described_class.empty do |config|
              config.add_host 'localhost', 3600
            end
          end

          it do
            is_expected.to have_attributes hosts: hosts
          end
        end

        context 'when given block adding databases' do
          subject do
            described_class.empty do |config|
              config.add_database 'SPSPEC', host: 'localhost' do |db|
                db[:db_user][:name] = 'specmaster'
                db[:db_user][:password] = 'masterpass'
                db[:sp_user] = 'specuser'
              end
            end
          end

          let :hosts do
            db_user = a_hash_including name: 'specmaster',
                                       password: 'masterpass'
            spspec = a_hash_including db_user: db_user,
                                      sp_user: 'specuser'
            databases = a_hash_including 'SPSPEC' => spspec
            localhost = a_hash_including databases: databases
            a_hash_including 'localhost' => localhost
          end

          it { is_expected.to have_attributes hosts: hosts }
        end
      end

      describe '#add_host' do
        subject(:add_host) { config.add_host 'localhost', 3600 }

        context 'when adding a new host' do
          it do
            expect { add_host }
              .to change(config, :hosts).from(be_empty).to hosts
          end
        end

        context 'when adding an existing host' do
          before { config.add_host 'localhost' }

          it do
            expect { add_host }
              .to raise_error 'Host \'localhost\' already configured'
          end
        end
      end

      describe '#add_database' do
        subject :add_database do
          config.add_database 'SPSPEC', host: 'localhost' do |db|
            db[:db_user][:name] = 'specmaster'
            db[:db_user][:password] = 'masterpass'
            db[:sp_user] = 'specuser'
          end
        end

        let :databases do
          db_user = a_hash_including name: 'specmaster',
                                     password: 'masterpass'
          spspec = a_hash_including db_user: db_user,
                                    sp_user: 'specuser'
          a_hash_including 'SPSPEC' => spspec
        end


        context 'when the database is not configured for the host' do
          let :localhost_db do
            localhost = a_hash_including port: nil,
                                         databases: databases
            a_hash_including 'localhost' => localhost
          end

          it do
            expect { add_database }
              .to change(config, :hosts)
              .from(be_empty).to(localhost_db)
          end
        end

        context 'when the database is already configured for the host' do
          before { config.add_database 'SPSPEC', host: 'localhost' }

          let(:e) { 'Database \'SPSPEC\' on \'localhost\' already configured' }

          it do
            expect { add_database }
              .to raise_error e
          end
        end
      end

      describe '#map_host' do
        subject :map_host do
          config.map_host 'localhost', directory: 'specify_dir'
        end

        context 'when the directory is not mapped' do
          it do
            expect { map_host }
              .to change(config, :dir_names)
              .from(be_empty).to a_hash_including 'specify_dir' => 'localhost'
          end
        end

        context 'when the directory is mapped' do
          before { config.map_host 'production', directory: 'specify_dir' }

          let(:e) { 'Directory \'specify_dir\' already mapped' }

          it do
        	  expect { map_host }.to raise_error e
        	end
        end
      end
    end
  end
end
