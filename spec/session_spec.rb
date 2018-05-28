# frozen_string_literal: true

# DB = Sequel.connect('mysql2://specmaster:masterpass@localhost:3306/SPSPEC')
# require_relative '../lib/target_model'

module SPResource
  module Specify
    RSpec.describe Session do
      let :session do
        described_class.new(SPSPEC, 'specuser', 'Test Collection')
      end

      it 'returns the user name' do
        expect(session.user).to be_a SPResource::Specify::Model::User
      end

      it 'opens a session' do
        expect { session.open }
          .to change { SPSPEC.sessions }
          .from([])
          .to a_collection_including an_instance_of Session
        session.close
      end

      it 'closes a session' do
        session.open
        expect { session.close }
          .to change { SPSPEC.sessions }
          .from(a_collection_including an_instance_of(Session))
          .to []
      end
    end
  end
end
