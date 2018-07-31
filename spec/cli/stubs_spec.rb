# frozen_string_literal: true

module Specify
  module CLI
    RSpec.describe 'stubs' do
      let :opts do
        geo = 'Continent: North America; Country: United States;'\
              ' locality: Springfield'
        {
          accession: "2018-AA-001",
          cataloger: "specuser",
          dataset: "Test dataset",
          geography: geo,
          locality: "Not transcribed",
          taxon: "Kingdom: Plantae; Division: Tracheophyta",
          preptype: "Sheet",
          prepcount: "1",
          file: nil
        }
      end

      let :stub_params do
        {
          "dataset_name" => "Test dataset",
          "cataloger" => "specuser",
          "accession" => "2018-AA-001",
          "collecting_data" => { "Continent" => "North America",
                                 "Country" => "United States",
                                 locality: 'Springfield' },
          "default_locality_name" => "Not transcribed",
          "determination" => { "Kingdom" => "Plantae",
                               "Division" => "Tracheophyta" },
          "preparation" => { type: "Sheet", count: "1" }
        }
      end

      describe '.stub_parameters' do
      	subject { CLI.stub_parameters opts }

      	it { is_expected.to eq stub_params }
      end
    end
  end
end
