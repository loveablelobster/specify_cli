# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TreeCrawler do
      let :crab_crawler do
        described_class.new id: '51294cac34ebedd85418f7d880fd7fa5'
      end

      let :crayfish_crawler do
      	described_class.new name: 'Astacidae', rank: 'Family'
      end

      let :taxonomy do
        Model::Taxonomy.first
      end

# how to fill ancestry
# unless tx
#   prnt = t.classification.pop
#   tx = taxonomy.names_dataset.first Name: prnt['name']
#   unless tx
#     inv_ancestry << prnt
#     prnt = t.classification.pop
#     tx = taxonomy.names_dataset.first Name: prnt['name']
#     unless tx
#       inv_ancestry << prnt
#       prnt = t.classification.pop
#       tx = taxonomy.names_dataset.first Name: prnt['name']
#       unless tx
#         inv_ancestry << prnt
#         prnt = t.classification.pop
#         tx = taxonomy.names_dataset.first Name: prnt['name']
#         puts tx
#         puts inv_ancestry
#       end
#     end
#   end

      describe '#crawl' do
        subject(:crawl_crayfish) do
          crayfish_crawler.crawl() do |child|
            # iterate creating Equivalents
            equivalent = Equivalent.new taxonomy, child
            tx = equivalent.find || equivalent.create
            equivalent.missing_synonyms.each do |s|
              if s.rank >= equivalent.rank
                ptx = equivalent.parent_taxon.parent_taxon
              else
                ptx = equivalent.parent_taxon
              end
              sn = s.create(ptx)
              sn.accepted_name = tx
              sn.save
            end
            p equivalent.internal
          end
        end

#         it do
#           subject
#         end
      end

      describe '#root' do
      	subject(:crab_root) { crab_crawler.root }

      	it do
      	  expect(crab_root)
      	    .to be_a(Taxon)
      	    .and have_attributes(name: 'Cancer', rank: GENUS)
      	end
      end
    end
  end
end
