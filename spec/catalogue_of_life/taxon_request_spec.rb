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
    end
  end
end
