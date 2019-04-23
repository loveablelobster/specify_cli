# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe Taxon do
      let(:asaphus) { described_class.first Name: 'Asaphus' }
      describe '#taxon_rank' do
        subject { asaphus.taxon_rank }

        it { p subject }
      end
    end
  end
end
