# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonResponse do
      let :cancer_pagurus do
        described_class.new(Psych.load_file('spec/support/taxon_response.yaml')
                                 .fetch :accepted_with_synonyms)
      end

      describe '#id' do
        subject { cancer_pagurus.id }

        it { p subject }
      end
    end
  end
end
