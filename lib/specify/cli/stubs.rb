# frozen_string_literal: true

module Specify
  module CLI
    # Transforms +arg+ (a String passed as a command line argument) containing
    # hierarchical information (such as geographic or taxonomic) into a
    # structured Hash that can be used to set the
    # Specify::Service::StubGenerator#collecting_data= or
    # Specify::Service::StubGenerator#determination=.
    def self.arg_to_hash(arg)
      return unless arg
      arg.split(';')
         .map { |pair| pair.split(':').map(&:strip) }
         .to_h
         .transform_keys { |key| key == 'locality' ? key.to_sym : key }
    end

    # Creates stub records with +generator+ (a Specify::Service::StubGenerator).
    #
    # +count+: the number of stub records to be created.
    def self.make_stubs(generator, count)
      STDERR.puts "started creating #{count} records"
      STDERR.puts "cataloger: #{generator.cataloger}"
      generator.database.transaction do
        generator.create count
        STDERR.puts "creating: #{generator.generated.last.catalog_number}"
      end
      STDERR.puts 'done'
      puts "generated #{generator.generated.count} catalog numbers:"
      puts '--------------------------'
      generator.generated.each { |co| puts co.CatalogNumber }
    end

    # Returns a Hash for intialization of a Specify::Service::StubGenerator
    # from +global_options+, +args+, and command +options+.
    def self.wrap_args(global_options, args, options)
      params = {}
      stub_generator = {}
      stub_generator[:host] = global_options[:host]
      stub_generator[:database] = global_options[:database]
      stub_generator[:collection] = args.shift
      stub_generator[:specify_user] = global_options[:specify_user]
      stub_generator[:config] = global_options[:db_config]
      params[:stub_generator] = stub_generator
      params.merge stub_parameters(options)
    end

    # Parses the parameters for stub records to created by a
    # Specify::Service::StubGenerator from the command +options+.
    def self.stub_parameters(options)
      params = { 'dataset_name' => options[:dataset],
                 'cataloger' => options[:cataloger],
                 'accession' => options[:accession],
                 'collecting_data' => arg_to_hash(options[:geography]),
                 'default_locality_name' => options[:locality],
                 'determination' => arg_to_hash(options[:taxon]) }
      return params unless options[:preptype]
      params['preparation'] = { type: options[:preptype],
                                count: options[:prepcount] }
      params.compact
    end
  end
end
