# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonResponse do
      let :crayfish_yaml do
        Psych.load_file('spec/support/taxon_response.yaml')[:valid_species]
      end

      let :crayfish do
        TaxonRequest.new(:json) do |req|
          req.name = 'Astacidae'
          req.rank = 'family'
        end
      end

      describe '#new' do
        subject { described_class.new() }

        it { p crayfish.results.first }
      end
    end
  end
end
