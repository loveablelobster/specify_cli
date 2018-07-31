# frozen_string_literal: true

module Specify
  module CLI
    def self.arg_to_hash(arg)
      arg.split(';')
         .map { |pair| pair.split(':').map(&:strip) }
         .to_h
         .transform_keys { |key| key == 'locality' ? key.to_sym : key }
    end

    def self.make_stubs(wrapped_args, count)
      stub_generator = Specify::Service::StubGenerator.unwrap wrapped_args
      stub_generator.database.transaction do
        stub_generator.create count
      end
      stub_generator.session.close
      # log stub_generator.generated
    end

    def self.wrap_args(global_options, args, options)
      params = {}
      stub_generator = {}
      stub_generator[:host] = global_options[:host]
      stub_generator[:database] = args.shift
      stub_generator[:collection] = args.shift
      stub_generator[:specify_user] = global_options[:specify_user]
      stub_generator[:config] = global_options[:db_config]
      params[:stub_generator] = stub_generator
      params.merge stub_parameters(options)
    end

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
