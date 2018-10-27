# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonRequest do
      let :crayfish do
        described_class.new(:json) do |req|
          req.name = 'Astacus astacus'
          req.rank = 'species'
        end
      end

      describe '#get' do
        subject { crayfish.get }

        it do
          p subject
        end
      end

      describe '#params' do
        subject(:params) { crayfish.params }

        it do
          expect(params).to include 'format' => 'json',
                                    'response' => 'full',
                                    'name' => 'Astacus astacus',
                                    'rank' => 'species'
        end
      end

      describe '#results' do
        subject { crayfish.results }

        it pending 'should filter multiple results'
      end
    end
  end
end
