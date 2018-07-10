# frozen_string_literal: true

# Tests for the
module Specify
  module Configuration
    RSpec.describe DBConfig do
      let :config do
        file = Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
        described_class.new('localhost', 'SPSPEC', file)
      end

      describe '#connection' do
        subject { config.connection }

        it do
          is_expected
            .to be_a(Hash)
            .and include host: 'localhost',
                         port: 3306,
                         user: 'specmaster',
                         password: 'masterpass'
        end
      end

      describe '#params' do
        subject { config.params }

        it do
          is_expected
            .to include port: 3306,
                        db_user: a_hash_including(name: 'specmaster',
                                                  password: 'masterpass'),
                        sp_user: 'specuser'
        end
      end

      describe 'session_user#' do
        subject { config.session_user }

        it { is_expected.to eq 'specuser' }
      end
    end
  end
end
