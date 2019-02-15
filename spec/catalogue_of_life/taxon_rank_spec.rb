# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonRank do
      describe '#stem' do
      	context 'when prefixed' do
      		subject { described_class.new('Subfamily').stem }

      		it { p subject }
      	end

      	context 'when not prefixed' do
      		subject { described_class.new('Family').stem }

      		it { p subject }
      	end
      end

      describe '#<=>' do
        let(:superfamily) { described_class.new('Superfamily') }
        let(:family) { described_class.new('Family') }
        let(:genus) { described_class.new('Genus') }

        context 'when equal' do
      	  subject { family == described_class.new('Family') }

      		it { is_expected.to be_truthy }
      	end

      	context 'when self is lesser' do
      		subject { family < superfamily }

          it { is_expected.to be_truthy }
      	end

      	context 'when self is greater' do
      		subject { family > genus }

      		it { is_expected.to be_truthy }
      	end
      end

      describe '#equivalent'

      describe '#position'

      describe '#to_s'

      describe '#valid?'
    end
  end
end
