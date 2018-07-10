# frozen_string_literal: true

# Tests for the
module Specify
  module Configuration
    RSpec.describe HostConfig do
      let :config do
        file = Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
        described_class.new(file)
      end

      describe '#params' do
        subject { config.params }

        it { is_expected.to include 'sp_resource' => 'localhost' }
      end

      describe '#resolve_host' do
      	subject { config.resolve_host('sp_resource') }

        it { is_expected.to eq 'localhost' }
      end
    end
  end
end
