# frozen_string_literal: true

module Specify
  module Service
    # A class that generates collection object stub records in a collection.
    class StubGenerator < Service
      attr_reader :accession,
                  :cataloger,
                  :collecting_geography,
                  :geography,
                  :locality,
                  :preparation_count,
                  :preparation_type,
                  :taxon,
                  :taxonomy

      def initialize(host:,
                     database:,
                     collection:,
                     specify_user:
                     nil,
                     config: nil)
        super
        @accession = nil
        @cataloger = agent
        @collecting_geography = nil
        @locality = nil
        @preparation_type = nil
        @preparation_count = nil
        @taxon = nil
        @taxonomy = discipline.taxonomy
        @geography = discipline.geography
        yield(self) if block_given?
      end

      # -> StubGenerator
      # Loads a YAML _file_ and creates an instance according to specifications
      # in the file.
      def self.load_yaml(file)
        #
      end

      # -> Model::Accession
      # <em>accession_number</em>: String
      def accession=(accession_number)
        @accession = division.accessions_dataset
                             .first AccessionNumber: accession_number
      end

      # -> Model::Agent
      # <em>user_name</em>: String
      def cataloger=(user_name)
        @cataloger = Model::User.first(Name: user_name)
                                .agents_dataset.first division: division
      end

      # -> Model::Locality
      # _geography_: Hash
      #              { 'Administrative division name' => 'Geographic name' }
      def collecting_data=(higher_geography:, locality: nil)
        @collecting_geography = geography.search_tree(higher_geography)
      end

      # -> Model::Taxon
      # _taxon_: String
      def determination=(taxon:, rank: nil)
        @taxon = taxonomy.taxa_dataset.first Name: taxon,
                                             rank: taxonomy.rank(rank)
      end

      # <em>prep_type</em>: String
      # _count_: Integer
      def preparation=(type:, count: nil)
        @preparation_type = collection.preparation_types_dataset
                                      .first Name: type
        @preparation_count = count
      end

      def create(count)
        #  DB.transaction do
        count.times do
          co = collection.add_collection_object(cataloger: cataloger)
          co.accession = accession
          co.georeference(locality: locality) if locality
          co.identify(taxon: taxon) if taxon
          co.save
          next unless preparation_type
          co.add_preparation collection: collection,
                             preparation_type: preparation_type,
                             CountAmt: preparation_count
          # TODO: log co.CatalogNumber
        end
        # end
      end
    end
  end
end
