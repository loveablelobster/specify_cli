# frozen_string_literal: true

module Specify
  module Service
    # A class that generates collection object stub records in a collection.
    class StubGenerator < Service
      attr_reader :accession,
                  :cataloger,
                  :collecting_geography,
                  :collecting_locality,
                  :preparation_count,
                  :preparation_type,
                  :taxon

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
        @collecting_locality = nil
        @preparation_type = nil
        @preparation_count = nil
        @taxon = nil
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
      def collecting_data=(higher_geography: nil, locality: nil)
        if higher_geography
          @collecting_geography = geography.search_tree(higher_geography)
        end
        localities = @collecting_geography&.localities_dataset ||
                     Model::Locality.dataset
        locality_matches = localities.where LocalityName: locality
        raise Model::AMBIGUOUS_MATCH_ERROR if locality_matches.count > 1
        @collecting_locality = locality_matches.first
      end

      # -> Model::Taxon
      # _taxon_: Hash { 'Rank name' => 'Taxon name' }
      def determination=(taxon)
        p taxon
        @taxon = taxonomy.search_tree taxon
      end

      def geography
        discipline.geography
      end

      # <em>prep_type</em>: String
      # _count_: Integer
      def preparation=(type:, count: nil)
        @preparation_type = collection.preparation_types_dataset
                                      .first Name: type
        @preparation_count = count
      end

      def taxonomy
        discipline.taxonomy
      end

      def create(count)
        #  DB.transaction do
        count.times do
          co = collection.add_collection_object(cataloger: cataloger)
          co.accession = accession
          co.georeference(locality: collecting_locality) if collecting_locality
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
