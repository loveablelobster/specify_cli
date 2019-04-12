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
          crayfish_crawler.crawl() do |child| # pass in second arg if possible
#             puts child.name
            rank = child.rank.equivalent(taxonomy)

#             taxon = child.parent.equivalent(taxonomy)
            taxon = taxonomy.names_dataset.first(TaxonomicSerialNumber: child.parent)
            puts "#{taxon}!!!!!!!!!!!" if taxon
            unless taxon
              prnt = child.full_response['classification'].last
              puts "???????????#{prnt}"
              raise 'No parent' unless prnt
              rnk = TaxonRank.new(prnt['rank']).equivalent(taxonomy)
              taxon = taxonomy.names_dataset.first(Name: prnt['name'])
            end

            tx = child.equivalent(taxonomy) ||
              taxon.add_child(Name: child.name,
                              IsAccepted: true,
                              IsHybrid: false,
                              rank: rank,
                              RankID: rank.RankID,
                              TaxonomicSerialNumber: child.id)
            child.equivalent(taxonomy)
          end
        end

        it do
#           p subject
        end
      end

      describe '#root' do
      	subject(:crab_root) { crab_crawler.root }

      	it do
      	  expect(crab_root)
      	    .to be_a(TaxonResponse)
      	    .and have_attributes(name: 'Cancer', rank: GENUS)
      	end
      end
    end
  end
end
