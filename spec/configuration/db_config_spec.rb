# frozen_string_literal: true

# Tests for the
module Specify
  module Configuration
    RSpec.describe DBConfig do
      let :file do
        Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      let :known_config do
        described_class.new('localhost', 'SPSPEC',
                            Pathname.new(Dir.pwd).join('spec',
                                                       'support',
                                                       'db.yml'))
      end

      let :unknown_config do
        described_class.new('localhost', 'SPECBase',
                            Pathname.new(Dir.pwd).join('spec',
                                                       'support',
                                                       'db.yml'))
      end

      describe '#connection' do
        context 'when the database is known' do
          subject { known_config.connection }

          it do
            is_expected.to be_a(Hash)
              .and include host: 'localhost',
                           port: 3306,
                           user: 'specmaster',
                           password: 'masterpass'
          end
        end

        context 'when the database is not known' do
          subject(:connection) { unknown_config.connection }

          let(:error) { 'SPECBase on localhost not configured' }

          it do
            expect { connection }.to raise_error error
          end
        end
      end

      describe '#db_user' do
        context 'when the database is known' do
          subject { known_config.db_user }

          it do
            is_expected
              .to be_a(Hash)
              .and include name: 'specmaster', password: 'masterpass'
          end
        end

        context 'when the database is not kown' do
          subject { unknown_config.db_user }

          it do
            is_expected
              .to be_a(Hash)
              .and include name: nil, password: nil
          end
        end
      end

      describe '#host?' do
        context 'when the host is known' do
          subject { known_config.host? }

          it { is_expected.to be_truthy }
        end

        context 'when the host is not known' do
          subject { described_class.new('cloudhost', 'SPSPEC', file).host? }

          it { is_expected.to be_falsey }
        end
      end

      describe '#known?' do
        context 'when the database is known' do
          subject { known_config.known? }

          it { is_expected.to be_truthy }
        end

        context 'when the database is not known' do
          subject { unknown_config.known? }

          it { is_expected.to be_falsey }
        end
      end

      describe '#params' do
        context 'when the database is known' do
          subject { known_config.params }

          it do
            is_expected
              .to include db_user: a_hash_including(name: 'specmaster',
                                                    password: 'masterpass'),
                          sp_user: 'specuser'
          end
        end

        context 'when the database is not known' do
          subject { unknown_config.params }

          it { is_expected.to be_nil }
        end
      end

      describe '#port=(number)' do
        context 'when passed a valid port number as string' do
          subject(:set_port) { known_config.port = '4000' }

          it do
            expect { set_port }
              .to change(known_config, :port).from(3306).to 4000
          end
        end

        context 'when passed a valid port number as integer' do
          subject(:set_port) { known_config.port = 4000 }

          it do
            expect { set_port }
              .to change(known_config, :port).from(3306).to 4000
          end
        end

        context 'when passed nil' do
          subject(:set_port) { known_config.port = nil }

          it do
            expect { set_port }
              .to change(known_config, :port).from(3306).to be_nil
          end
        end

        context 'when passed an invalid port number' do
          subject(:set_port) { known_config.port = 'default' }

          it do
            expect { set_port }
              .to raise_error ArgumentError, 'invalid port number: default'
          end
        end
      end

      describe '#save' do
        before { @original_file = Psych.load_file file }

        context 'when the database is knwon' do
          subject(:save_config) { known_config.save }

          before do
            known_config.port = 4000
            known_config.user_name = 'dbtester'
            known_config.user_password = 'supersecret'
            known_config.session_user = 'tester'
          end

          it do
            keypath = [:hosts, 'localhost', :port]
            expect { save_config }
              .to change { Psych.load_file(file).dig(*keypath) }
              .from(3306).to 4000
          end

          it do
            keypath = [:hosts, 'localhost',
                       :databases, 'SPSPEC', :db_user, :name]
            expect { save_config }
              .to change { Psych.load_file(file).dig(*keypath) }
              .from('specmaster').to 'dbtester'
          end

          it do
            keypath = [:hosts, 'localhost',
                       :databases, 'SPSPEC', :db_user, :password]
            expect { save_config }
              .to change { Psych.load_file(file).dig(*keypath) }
              .from('masterpass').to 'supersecret'
          end

          it do
            keypath = [:hosts, 'localhost',
                       :databases, 'SPSPEC', :sp_user]
            expect { save_config }
              .to change { Psych.load_file(file).dig(*keypath) }
              .from('specuser').to 'tester'
          end
        end

        context 'when the database is not known' do
          subject(:save_config) { unknown_config.save }

          before do
            unknown_config.port = 4000
          end

          it do
            keypath = [:hosts, 'localhost', :databases]
            expect { save_config }
              .to change { Psych.load_file(file).dig(*keypath) }
              .to include('SPECBase')
          end

          it do
            keypath = [:hosts, 'localhost', :port]
            expect { save_config }
              .to change { Psych.load_file(file).dig(*keypath) }
              .from(3306).to 4000
          end
        end

        context 'when the host is not known' do
          subject :save_config do
            described_class.new('cloudhost', 'SPSPEC', file).save
          end

          it do
            expect { save_config }
              .to change { Psych.load_file(file)[:hosts] }
              .to include 'cloudhost'
          end
        end

        after do
          File.open(file, 'w') do |f|
            f.write(Psych.dump(@original_file))
          end
        end
      end

      describe '#changed_user?' do
        subject { known_config.changed_user? }

        context 'when the user has not changed' do
          it { is_expected.to be_falsey }
        end

        context 'when the user has changed' do
          before { known_config.user_name = 'tester' }

          it { is_expected.to be_truthy }
        end
      end

      describe '#changed_password?' do
        subject { known_config.changed_password? }

        context 'when the user has not changed' do
          it { is_expected.to be_falsey }
        end

        context 'when the user has changed' do
          before { known_config.user_password = 'supersecret' }

          it { is_expected.to be_truthy }
        end
      end

      describe '#changed_port?' do
        subject { known_config.changed_port? }

        context 'when the user has not changed' do
          it { is_expected.to be_falsey }
        end

        context 'when the user has changed' do
          before { known_config.port = 3307 }

          it { is_expected.to be_truthy }
        end
      end

      describe '#changed_session_user?' do
        subject { known_config.changed_session_user? }

        context 'when the user has not changed' do
          it { is_expected.to be_falsey }
        end

        context 'when the user has changed' do
          before { known_config.session_user = 'tester' }

          it { is_expected.to be_truthy }
        end
      end
    end
  end
end
