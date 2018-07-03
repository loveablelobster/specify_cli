# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe AutoNumberingScheme do
      let :collection do
        Collection.first CollectionName: 'Test Collection'
      end

      it 'bla' do
        AutoNumberingScheme.dataset.each do |ans|
          puts "Collections: #{ans.collections}" unless ans.collections.empty?
          puts "Disciplines: #{ans.disciplines}" unless ans.disciplines.empty?
          puts "Divisions: #{ans.divisions}" unless ans.divisions.empty?
        end
        p collection.auto_numbering_schemes
        puts
        ans = AutoNumberingScheme.first
        p ans.max
      end
    end
  end
end
