# frozen_string_literal: true

#
module Specify
  # Tests for the Specify module
  RSpec.describe Database do
    let(:db) { SPSPEC }
    let(:session) { Session.new('specuser', 'Test Collection') }

    let :config do
      Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
    end

    describe '.load_config(hostname, database, config_file)' do
      subject { described_class.load_config('localhost', 'SPSPEC', config) }

      it do
        is_expected.to be_a(Database)
          .and have_attributes host: 'localhost',
                               database: 'SPSPEC',
                               port: 3306,
                               user: 'specmaster'
      end
    end

    describe '#<<(session)' do
      it do
        expect { SPSPEC << session }
          .to change(db, :sessions)
          .from(be_empty)
          .to including(an_instance_of(Session))
      end

      after { db.close }
    end

    describe '#close' do
      before do
        db << session
      end

      it do
        expect { db.close }
          .to change(db, :sessions)
          .from(including(an_instance_of(Session)))
          .to be_empty
      end
    end

    describe '#connect' do
      subject { db.connect }

      it do
        is_expected.to be_a(Sequel::Mysql2::Database)
         .and have_attributes opts: a_hash_including(user: 'specmaster',
                                                     host: 'localhost',
                                                     port: 3306,
                                                     database: 'SPSPEC')
      end
    end

#     describe '#start_session(user, collection)' do
#       let :collection do
#         Model::Collection.first CollectionName: 'Test Collection'
#       end
#
#       let(:user) { Model::User.first Name: 'specuser' }
#
#       it do
#         expect { db.start_session('specuser', 'Test Collection') }
#           .to change(db, :sessions)
#           .from(be_empty)
#           .to including(an_instance_of(Session))
#       end
#
#       after { db.close }
#     end

    it 'returns a database connection' do
      expect(SPSPEC.connect).to be_a_kind_of Sequel::Database
    end
  end
end
