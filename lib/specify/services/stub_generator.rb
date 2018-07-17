# frozen_string_literal: true

module Specify
  module Service
    # A class that generates collection object stub records in a collection.
    class StubGenerator < Service
      attr_reader :accession,
                  :cataloger,
                  :collecting_geography,
                  :collecting_locality,
                  :default_locality,
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
        @default_locality = nil
        @preparation_type = nil
        @preparation_count = nil
        @taxon = nil
        yield(self) if block_given?
      end

      # -> StubGenerator
      # Loads a YAML _file_ and creates an instance according to specifications
      # in the file.
      def self.load_yaml(file)
        # load YAML file here
      end

      # -> Model::Accession
      # Sets the instance's _accession_ to the Model::Accession with the passed
      # <em>accession_number</em> (String).
      def accession=(accession_number)
        @accession = division.accessions_dataset
                             .first AccessionNumber: accession_number
        raise ACCESSION_NOT_FOUND_ERROR + accession_number unless accession
      end

      # -> Model::Agent
      # Sets the instance's _cataloger_ to the Model::Agent representing the
      # Model::User in the instance's _division_.
      # <em>user_name</em>: String
      def cataloger=(user_name)
        cataloger_user = Model::User.first(Name: user_name)
        raise USER_NOT_FOUND_ERROR + user_name unless cataloger_user
        @cataloger = cataloger_user.agents_dataset.first division: division
      end

      # -> Model::Locality
      # Sets the instance's <em>collecting_geography</em> and
      # <em>collecting_locality</em>.
      # _geography_: Hash
      #              { 'Administrative division name' => 'Geographic name',
      #                locality: 'Locality name' }
      def collecting_data=(vals)
        locality = vals.delete :locality
        @collecting_geography = geography.search_tree(vals) unless vals.empty?
        return unless locality
        @collecting_locality = find_locality locality
        raise LOCALITY_NOT_FOUND_ERROR + locality unless collecting_locality
      end

      # Sets the default locality.
      # Will create a Model::Locality in the instance's _localities_ dataset,
      # for the instance's <em>collecting_geography</em> if given, or
      # _discipline_.
      def default_locality=(locality_name = 'not cataloged, see label')
        @default_locality = find_locality locality_name
        return if @default_locality
        @default_locality = discipline
          .add_locality LocalityName: locality_name,
                        geographic_name: collecting_geography
      end

      # -> Model::Taxon
      # Sets the taxon to which stub records will be determined.
      # _taxon_: Hash { 'Rank name' => 'Taxon name' }
      def determination=(vals)
        @taxon = taxonomy.search_tree vals
        raise TAXON_NOT_FOUND_ERROR + vals.to_s unless taxon
      end

      # -> Model::Locality
      # Returns the Specify::Model::Locality for <em>locality_name</em> from
      # the instance's _discipline_'s locality dataset or the instance's
      # <em>collecting_geography</em>'s locality dataset.
      def find_locality(locality_name)
        locality_matches = localities.where LocalityName: locality_name
        raise Model::AMBIGUOUS_MATCH_ERROR if locality_matches.count > 1
        locality_matches.first
      end

      # -> Model::Geography
      # Returns the Specify::Model::Geography instance for the instance's
      # _discipline_.
      def geography
        discipline.geography
      end

      # -> Sequel::Dataset
      # Returns a Sequel::Dataset for the instances's
      # <em>collecting_geography</em> if it has one, otherwise for the
      # instance's _division_.
      def localities
        @collecting_geography&.localities_dataset ||
          discipline.localities_dataset
      end

      # ->
      # Sets the instance's <em>preparation_type</em> and
      # <em>preparation_count</em>
      # <em>prep_type</em>: String
      # _count_: Integer
      def preparation=(type:, count: nil)
        @preparation_type = collection.preparation_types_dataset
                                      .first Name: type
        raise PREPTYPE_NOT_FOUND_ERROR + type unless preparation_type
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
          co.geo_locate(locality: collecting_locality) if collecting_locality
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
