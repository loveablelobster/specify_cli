# frozen_string_literal: true

#
module SPResource
  # Tests for the Specify module
  module Specify
    RSpec.describe Database do
      let :config do
        Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      it 'returns the host' do
        db = described_class.new('foo', host: 'bar', password: 'baz')
        expect(db.host).to eq 'bar'
      end

      it 'returns the port' do
        db = described_class.new('foo', port: 123, password: 'bar')
        expect(db.port).to be 123
      end

      it 'returns a database connection' do
        expect(SPSPEC.connect).to be_a_kind_of Sequel::Database
      end

      it 'creates a new instance from a config file' do
        expect(described_class.load_config('SPSPEC', config))
          .to be_a_kind_of Database
      end
    end
  end
end
