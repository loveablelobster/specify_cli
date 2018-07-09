# frozen_string_literal: true

# Tests for the
module Specify
  RSpec.describe Configuration do
    context 'when creating instances from branch names' do
      let :config do
        file = Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      describe '#database_params(host, database)' do
        subject do
          described_class.new(file: config,
                              host: 'localhost',
                              database: 'SPSPEC').params
        end

        it do
          is_expected
            .to include 'port' => 3306,
                        'db_user' => a_hash_including('name' => 'specmaster',
                                                      'password' => 'masterpass'),
                        'sp_user' => 'specuser'
        end
      end
    end
  end
end
