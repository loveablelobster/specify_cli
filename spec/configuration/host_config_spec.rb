# frozen_string_literal: true

# Tests for the
module Specify
  module Configuration
    RSpec.describe HostConfig do
      let :config do
        file = Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
        described_class.new(file)
      end

      describe '#directory?(directory)' do
        context 'when the directory is known' do
          subject { config.directory? 'sp_resource' }

          it { is_expected.to be_truthy }
        end

        context 'when the directory is not known' do
          subject { config.directory? 'home' }

          it { is_expected.to be_falsey }
        end
      end

      describe '#map_directory(directory, host)' do
        subject :map_directory do
          config.map_directory 'documents', 'cloudhost'
        end

        context 'when the directory is not mapped' do
          it do
            expect { map_directory }
              .to change(config, :params).to include 'documents' => 'cloudhost'
          end
        end

        context 'when the directory is mapped' do
          before { config.map_directory 'documents', 'cloudhost' }

          let(:e) { 'Directory \'documents\' already mapped' }

          it do
        	  expect { map_directory }.to raise_error e
        	end
        end
      end

      describe '#params' do
        subject { config.params }

        it do
          is_expected.to include 'sp_resource' => 'localhost'
        end
      end

      describe '#resolve_host' do
      	subject { config.resolve_host('sp_resource') }

        it { is_expected.to eq 'localhost' }
      end
    end
  end
end
