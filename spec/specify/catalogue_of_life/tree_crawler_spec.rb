# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TreeCrawler do
      let :crab_crawler do
        described_class.new id: '51294cac34ebedd85418f7d880fd7fa5'
      end

      let :crayfish_crawler do
#       	described_class.new name: 'Astacidae', rank: 'Family'
      	described_class.new crayfish_equivalent, fill_lineage: true
      end

      let :crayfish_equivalent do
        Equivalent.new Factories::Model::Taxonomy.for_tests,
                       Request.by(name: 'Astacidae', rank: 'Family').taxon
      end

      let :taxonomy do
        Model::Taxonomy.first
      end

      describe '#crawl' do
        subject(:crawl_crayfish) do
          crayfish_crawler.crawl() do |child|
            tx = child.find || child.create
            child.missing_synonyms.each do |s|
              if s.rank >= child.rank
                ptx = child.parent.parent
              else
                ptx = child.parent
              end
              sn = s.create(ptx)
              sn.accepted_name = tx
              sn.save
            end
             p child.internal
          end
        end

        it do
          subject
        end
      end

      describe '#root' do
#       	subject(:crab_root) { crab_crawler.root }
#
#       	it do
#       	  expect(crab_root)
#       	    .to be_a(Taxon)
#       	    .and have_attributes(name: 'Cancer', rank: GENUS)
#       	end
      end
    end
  end
end
