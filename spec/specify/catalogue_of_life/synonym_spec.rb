# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe Synonym do
      # FIXME: move to shared variables for CoL spec suite
      let(:cancer_fimbriatus) { described_class.new(result :synonym) }
      let(:e_expansus) { described_class.new(result :new_combination) }

      describe '#classification' do
        context 'when rank is species' do
          subject(:ancestors) { cancer_fimbriatus.classification }

          it do
            expect(ancestors).to contain_exactly(
              an_instance_of(Taxon) &
                have_attributes(name: 'Animalia'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Arthropoda'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Malacostraca'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Decapoda'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Cancroidea'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Cancridae'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Cancer')
            )
          end
        end

        context 'when rank is subspecies' do
          #
        end

        context 'when a new combination' do
          subject(:ancestors) { e_expansus.classification }

          it do
            expect(ancestors).to contain_exactly(
              an_instance_of(Taxon) &
                have_attributes(name: 'Animalia'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Arthropoda'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Trilobita'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Not assigned'),
              an_instance_of(Taxon) &
                have_attributes(name: 'Not assigned')
            )
          end
        end
      end
    end
  end
end
