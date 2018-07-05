# frozen_string_literal: true

module Specify
  RSpec.describe NumberFormat do
    describe '#create' do
      subject { described_class.new(9).create(123) }

      it { is_expected.to eq '000000123' }
    end

    describe '#incrementer' do
      subject { described_class.new(9).incrementer('000000123') }

    	it { is_expected.to be 123 }
    end

    describe '#template' do
      subject { described_class.new(9).template }

      it { is_expected.to eq '#########' }
    end

    describe '#to_regexp' do
      subject { described_class.new(9).to_regexp }

    	it { is_expected.to eq /^(?<incrementer>\d{9})$/ }
    end
  end
end
