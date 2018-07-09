# frozen_string_literal: true

#
module Specify
  # Tests for the Specify module
  module Specify
    RSpec.describe Database do
      let(:db) { SPSPEC }

      describe '.load_config(hostname, database, config_file)' do
        let :config do
          Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
        end

        subject { described_class.load_config('localhost', 'SPSPEC', config)}

        it do
          is_expected.to be_a_kind_of(Database)
            .and have_attributes host: 'localhost',
                                 database: 'SPSPEC',
                                 port: 3306,
                                 user: 'specmaster'
        end
      end

      describe '#<<(session)' do
        let(:session) { Session.new('specuser', 'Test Collection') }

        before(:all) { SPSPEC.sessions.each { |s| s.close } }

        context 'when session is open' do
          before { session.open }

        	it do
        	  SPSPEC.sessions.each { |s| p s }
        		expect { SPSPEC << session }
        		  .to change { SPSPEC.sessions }
        		  .from(be_empty)
        		  .to(a_collection_including(an_instance_of(Session)))
        	end
        end
        context 'when session is not open'
      end

      describe '#close'
      describe '#connect'
      describe '#start_session'
      describe '#update'

      it 'returns a database connection' do
        expect(SPSPEC.connect).to be_a_kind_of Sequel::Database
      end
    end
  end
end
