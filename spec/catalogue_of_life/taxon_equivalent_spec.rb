# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonEquivalent do
      let :asaphida_resp do
        TaxonResponse.new(Psych.load_file('spec/support/taxon_response.yaml')
                               .fetch :asaphida)
      end

      let :asaphoidea_resp do
        TaxonResponse.new(Psych.load_file('spec/support/taxon_response.yaml')
                               .fetch :asaphoidea)
      end

      let :asaphidae_resp do
        TaxonResponse.new(Psych.load_file('spec/support/taxon_response.yaml')
                               .fetch :asaphidae)
      end

      let :asaphus_resp do
        TaxonResponse.new(Psych.load_file('spec/support/taxon_response.yaml')
                               .fetch :asaphus)
      end

      describe '#find_by_id' do
        let :asaphida_eq do
          described_class.new(spec_taxonomy,
                              asaphida_resp)
        end

      	it { p asaphida_eq }
      end
    end
  end
end
