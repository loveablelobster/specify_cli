# frozen_string_literal: true

module Specify
  module Service
    # A StubGenerator creates Specify::Model::CollectionObject stub records
    # (mostly empty records with a minmum of information) in collection in a
    # Specify::Database.
    class StubGenerator < Service
      # An existing Specify::Model::Accession.
      attr_reader :accession

      # An existing Specify::Model::Agent.
      attr_reader :cataloger

      # An existing Specify::Model::GeographicName.
      attr_reader :collecting_geography

      # An existing Specify::Model::Locality.
      attr_reader :collecting_locality

      # String; the name for the #record_set that will be created for the
      # generated Specify::Model::CollectionObject records.
      attr_accessor :dataset_name

      # String; the name of the Specify::Model::Locality that will be created if
      # no existing Specify::Model::Locality is passed via #collecting_data=.
      attr_accessor :default_locality_name

      # Integer. See Specify::Model::Preparation#count.
      attr_reader :preparation_count

      # An existing Specify::Model::PreparationType.
      attr_reader :preparation_type

      # A Specify::Model::RecordSet.
      attr_reader :record_set

      # An existing Specify::Model::Taxon.
      attr_reader :taxon

      # Returns a new StubGenerator with attributes from a YAML +file+.
      #
      # +file+ should have the structure:
      #     ---
      #     :stub_generator:
      #       :host: <hostname>
      #       :database: <database name>
      #       :collection: <collection name>
      #       :config: <database configuration file>
      #     dataset_name: <record set name>
      #     accession: <accession number>
      #     cataloger: <specify user name>
      #     collecting_data:
      #       <1st rank>: <name>
      #       <2nd rank>: <name>
      #       <3rd rank>: <name>
      #       :locality: <name>
      #     default_locality_name: <name>
      #     determination:
      #       <1st rank>: <name>
      #       <2nd rank>: <name>
      #       <3rd rank>: <name>
      #     preparation:
      #       :type: <preparation type>
      #       :count: <preparation count>
      #
      # Items prefixed with +:+ in the example above will be deserialized as
      # Ruby symbols and need to be prefixed with +:+ in the file. Leave out any
      # items that are not to be set. The section +:stub_generator:+ is
      # required.
      def self.load_yaml(file)
        unwrap Psych.load_file(file)
      end

      # Returns a new StubGenerator with attributes from +hash+.
      #
      # +hash+ should have the structure
      # {
      #   stub_generator: {
      #     host: <hostname>,
      #     database: <database name>,
      #     collection: <collection name>,
      #     config: <database configuration file>
      #   },
      #   dataset_name => <record set name>,
      #   accession => <accession number>,
      #   cataloger => <specify user name>,
      #   collecting_data => {
      #     <1st rank> => <name>,
      #     <2nd rank> => <name>,
      #     <3rd rank> => <name>,
      #     locality: <name>
      #   },
      #   default_locality_name => <name>,
      #   determination => {
      #     <1st rank> => <name>,
      #     <2nd rank> => <name>,
      #     <3rd rank> => <name>
      #   },
      #   preparation => {
      #     type: <preparation type>,
      #     count: <preparation count>
      #   }
      # }
      # Items that are symbols in the example above need to be symbols in the
      # +hash+ passed. Leave out any items that are not to be set. The key
      # +:stub_generator+ is required.
      def self.unwrap(hash)
        new hash.delete(:stub_generator) do |stubs|
          hash.each do |key, value|
            setter = (key + '=').to_sym
            puts "#{setter}#{value}"
            next unless value
            stubs.public_send(setter, value)
          end
        end
      end

      # Returns a new StubGenerator.
      def initialize(collection:,
                     config:,
                     host:,
                     database:,
                     specify_user: nil)
        super
        @accession = nil
        @cataloger = agent
        @collecting_geography = nil
        @collecting_locality = nil
        @default_locality_name = 'not cataloged, see label'
        @dataset_name = "stub record set #{Time.now}"
        @preparation_type = nil
        @preparation_count = nil
        @record_set = nil
        @taxon = nil
        yield(self) if block_given?
      end

      # Sets #accession to the Specify::Model::Accession with +accession_number+
      def accession=(accession_number)
        @accession = division.accessions_dataset
                             .first AccessionNumber: accession_number
        raise ACCESSION_NOT_FOUND_ERROR + accession_number unless accession
      end

      # Sets #cataloger to the Specify::Model::Agent representing the
      # Specify::Model::User with +user_name+ in #division.
      def cataloger=(user_name)
        cataloger_user = Model::User.first(Name: user_name)
        raise USER_NOT_FOUND_ERROR + user_name unless cataloger_user
        @cataloger = cataloger_user.agents_dataset.first division: division
      end

      # Sets #collecting_geography and #collecting_locality.
      #
      # +vals+ is a Hash with the structure <tt>{ 'rank' => 'name',
      # :locality => 'name' }</tt> where +rank+ is an existing
      # Specify::Model::AdministrativeDivision#name, +name+ an existing
      # Specify::Model::GeographicName#name with that rank. +:locality+ is not a
      # geographic rank and must be given as a symbol. When traversing a tree
      # hierarchy, give key value paris in descencing order of rank:
      #   { 'Country' => 'United States',
      #     'State' => 'Kansas',
      #     'County' => 'Douglas County',
      #     :locality => 'Freestate Brewery' }
      def collecting_data=(vals)
        locality = vals.delete :locality
        unless vals.empty?
          @collecting_geography = geography.search_tree(vals)
          unless @collecting_geography
            missing_geo = vals.values.join(', ')
            raise GEOGRAPHY_NOT_FOUND_ERROR + missing_geo
          end
        end
        return unless locality
        @collecting_locality = find_locality locality
        raise LOCALITY_NOT_FOUND_ERROR + locality unless collecting_locality
      end

      # Returns #collecting_locality or #default_locality if
      # #collecting_locality is +nil+ but #collecting_geography is not;
      # Will create the Specify::Model::GeographicName for #default_locality
      # if it does not exist in #localities.
      def collecting_locality!
        return collecting_locality if collecting_locality
        return unless collecting_geography
        default_locality!
      end

      # Creates +count+ records for Specify::Model::CollectionObject with the
      # attributes of +self+.
      def create(count)
        @record_set = collection.add_record_set Name: dataset_name,
                                                user: cataloger.user
        count.times do
          stub = create_stub
          @record_set.add_record_set_item collection_object: stub
        end
      end

      # Returns the Specify::Model::GeographicName for #default locality if it
      # exists.
      def default_locality
        find_locality default_locality_name
      end

      # Returns the Specify::Model::GeographicName for #default locality.
      # Creates the record if it does not exist in #localities.
      def default_locality!
        return default_locality if default_locality
        default_locality ||
          discipline.add_locality(LocalityName: default_locality_name,
                                  geographic_name: collecting_geography)
      end

      # Sets #taxon, to which stub records will be determined.
      # +vals+ is a Hash with the structure <tt>{ 'rank' => 'name' }</tt> where
      # +rank+ is an existing Specify::Model::Rank#name, +name+ an existing
      # Specify::Model::Taxon#name with that rank. When traversing a tree
      # hierarchy, give key value paris in descencing order of rank:
      #   { 'Phylum' => 'Arthropoda',
      #     'Class' => 'Trilobita',
      #     'Order' => 'Asaphida',
      #     'Family' => 'Asaphidae' }
      def determination=(vals)
        @taxon = taxonomy.search_tree vals
        raise TAXON_NOT_FOUND_ERROR + vals.to_s unless taxon
      end

      # Returns the Specify::Model::Locality for +locality_name+ in #localities.
      def find_locality(locality_name)
        locality_matches = localities.where LocalityName: locality_name
        raise Model::AMBIGUOUS_MATCH_ERROR if locality_matches.count > 1
        locality_matches.first
      end

      # Returns the Specify::Model::CollectionObject records in #record_set
      # (the records created by #create).
      def generated
        record_set&.collection_objects
      end

      # Returns the Specify::Model::Geography for #discipline.
      def geography
        discipline.geography
      end

      # Returns a Sequel::Dataset of Specify::Model::Locality records in
      # #collecting_geography or #division if #collecting_geography is +nil+.
      def localities
        @collecting_geography&.localities_dataset ||
          discipline.localities_dataset
      end

      # Sets #preparation_type and #preparation_count. +type+ must be an
      # existing Specify::Model::PreparationType#name. +count+ should be an
      # Integer.
      #
      # Returns an array with the #preparation_type and #preparation_count.
      def preparation=(type:, count: nil)
        @preparation_type = collection.preparation_types_dataset
                                      .first Name: type
        raise PREPTYPE_NOT_FOUND_ERROR + type unless preparation_type
        @preparation_count = count
        [preparation_type, preparation_count].compact
      end

      # Returns the Specify::Model::Taxonomy for #discipline.
      def taxonomy
        discipline.taxonomy
      end

      private

      def create_stub
        co = collection.add_collection_object(cataloger: cataloger)
        co.accession = accession
        co.geo_locate(locality: collecting_locality!) if collecting_locality!
        co.identify(taxon: taxon) if taxon
        make_preparation(co) if preparation_type
        co.save
      end

      def make_preparation(collection_object)
        collection_object.add_preparation collection: collection,
                                          preparation_type: preparation_type,
                                          CountAmt: preparation_count
      end
    end
  end
end
