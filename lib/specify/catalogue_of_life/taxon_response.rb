# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    #
    class TaxonResponse
      def initialize(col_result_hash)
        @id = col_result_hash['id']
        @name = col_result_hash['name']
        @author = col_result_hash['author']
        @name_status = col_result_hash['name_status']
        @rank = col_result_hash['rank']
      end
    end
  end
end


# +  "genus" => "Astacus",
# +  "subgenus" => "",
# +  "species" => "astacus",
# +  "infraspecies_marker" => "",
# +  "infraspecies" => "",
# +  "record_scrutiny_date" => { "scrutiny" => "31-May-2005" },
# -  "online_resource" => "http://www.itis.gov/servlet/SingleRpt/SingleRpt?search_topic=TSN&search_value=97333",
# +  "is_extinct" => "false",
# -  "source_database" => "ITIS Regional: The Integrated Taxonomic Information System",
# -  "source_database_url" => "http://www.itis.gov;\nhttp://www.cbif.gc.ca/acp/eng/itis/search (Canada)",
# -  "bibliographic_citation" => "Tom Orrell (custodian), Dave Nicolson (ed). (2018). ITIS Regional: The Integrated Taxonomic Information System (version Jun 2017). In: Roskov Y., Orrell T., Nicolson D., Bailly N., Kirk P.M., Bourgoin T., DeWalt R.E., Decock W., De Wever A., Nieukerken E. van, Zarucchi J., Penev L., eds. (2018). Species 2000 & ITIS Catalogue of Life, 31st July 2018. Digital resource at www.catalogueoflife.org/col. Species 2000: Naturalis, Leiden, the Netherlands. ISSN 2405-8858.",
# -  "name_html" => "<i>Astacus astacus</i> (Linnaeus, 1758)",
# +  "url" => "http://www.catalogueoflife.org/col/details/species/id/526387756aa5574c4879c6cc114248fd",
# -  "distribution" => "",
# -  "references" => [
# -    { "author" => nil, "year" => "1996", "title" => nil, "source" => "NODC Taxonomic Code"},
# -    { "author" => "Lundberg, Ulrich", "year" => "2004", "title" => "Behavioural elements of the noble crayfish, Astacus astacus (Linnaeus, 1758)", "source" => "Crustaceana, vol. 77, no. 2"}
# -  ],
# +  "classification" => [
# +   { "id" => "5ede24b0534ebd5e1f552d5b9f874a6a", "name" => "Animalia", "rank" => "Kingdom", "name_html" => "Animalia", "url" => "http://www.catalogueoflife.org/col/browse/tree/id/5ede24b0534ebd5e1f552d5b9f874a6a" },
# +   { "id" => "89ac18bfcf1654a9662a600ba06bb494", "name" => "Arthropoda", "rank" => "Phylum", "name_html" => "Arthropoda", "url" => "http://www.catalogueoflife.org/col/browse/tree/id/89ac18bfcf1654a9662a600ba06bb494" },
# +   { "id" => "86858bfbd5b0846611871d8eb3e25db1", "name" => "Malacostraca", "rank" => "Class", "name_html" => "Malacostraca", "url" => "http://www.catalogueoflife.org/col/browse/tree/id/86858bfbd5b0846611871d8eb3e25db1" },
# +   { "id" => "1008e23f49cf95fb6c80631ab5505d14", "name" => "Decapoda", "rank" => "Order", "name_html" => "Decapoda", "url" => "http://www.catalogueoflife.org/col/browse/tree/id/1008e23f49cf95fb6c80631ab5505d14" },
# +   { "id" => "f7e33c38480f906dd432fd88b13fe73a", "name" => "Astacoidea", "rank" => "Superfamily", "name_html" => "Astacoidea", "url" => "http://www.catalogueoflife.org/col/browse/tree/id/f7e33c38480f906dd432fd88b13fe73a" },
# +   { "id" => "2369699114e1f4c241019caf7f0ce43c", "name" => "Astacidae", "rank" => "Family", "name_html" => "Astacidae", "url" => "http://www.catalogueoflife.org/col/browse/tree/id/2369699114e1f4c241019caf7f0ce43c"},
# +   { "id" => "cf32418e84a35b0f3825a8825c3c967c", "name" => "Astacus", "rank" => "Genus", "name_html" => "<i>Astacus</i>", "url" => "http://www.catalogueoflife.org/col/browse/tree/id/cf32418e84a35b0f3825a8825c3c967c"}
# +  ],
# +  "child_taxa" => [],
# +  "synonyms" => [],
# +  "common_names" => []
