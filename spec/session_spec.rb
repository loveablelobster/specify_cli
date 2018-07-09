# frozen_string_literal: true

# DB = Sequel.connect('mysql2://specmaster:masterpass@localhost:3306/SPSPEC')
# require_relative '../lib/target_model'

module Specify
  RSpec.describe Session do
    let :session do
      described_class.new('specuser', 'Test Collection')
    end

    describe '#close' do
      let :collection do
        Model::Collection.first CollectionName: 'Test Collection'
      end

      let(:user) { Model::User.first Name: 'specuser' }

      before { user.log_in(collection) }

      it do
        expect(session.close)
          .to be_a(described_class)
          .and have_attributes active: false,
                               collection: collection,
                               user: user
      end

      it do
        expect { session.close }
          .to change { Model::User.first(Name: 'specuser').IsLoggedIn }
          .from(true).to(false)
      end

      context 'when observed by a database' do
        before { SPSPEC << session }

        it do
          expect { session.close }
            .to change { SPSPEC.sessions }
            .from(including(an_instance_of(described_class)))
            .to be_empty
        end
      end
    end

    describe '#open' do
      let :collection do
        Model::Collection.first CollectionName: 'Test Collection'
      end

      let(:user) { Model::User.first Name: 'specuser' }

      before { user.log_out }

      it do
        expect(session.open)
          .to be_a(described_class)
          .and have_attributes active: true,
                               collection: collection,
                               user: user
      end

      it 'opens a session' do
        expect { session.open }
          .to change { Model::User.first(Name: 'specuser').IsLoggedIn }
          .from(false).to(true)
      end
    end

    describe '#open?' do
      context 'when the session is open' do
        subject { session.open? }

        before { session.open }

        it { is_expected.to be_truthy }
      end

      context 'when the session is closed' do
        subject { session.open? }

        before { session.close }

        it { is_expected.to be_falsey }
      end
    end

    describe '#session_agent' do
      subject { session.session_agent }

      let :division do
        Model::Collection.first(CollectionName: 'Test Collection')
                         .discipline.division
      end

      before { session.open }

      it do
        is_expected.to be_a(Model::Agent)
          .and have_attributes Email: 'john.doe@example.com',
                               FirstName: 'John',
                               LastName: 'Doe',
                               division: division
      end
    end
  end
end
