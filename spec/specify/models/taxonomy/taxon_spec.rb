# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe Taxon do
      let(:asaphus) { described_class.first Name: 'Asaphus' }
    end
  end
end
