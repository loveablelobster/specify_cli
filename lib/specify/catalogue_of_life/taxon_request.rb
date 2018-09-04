# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    #
    class TaxonRequest
      # The Faraday::Connection for the request.
      attr_reader :conn

      # The format for the response, +:json+ or +:xml+.
      attr_accessor :content_type

      # CatalogueOfLife id of the taxon.
      attr_accessor :id

      # Name of the taxon to search for.
      attr_accessor :name

      # Rank of the taxon to search for (can be multiple).
      # if empty, all matches within any rank will be returned
      attr_accessor :rank

      # :full (default) or :terse. :terse will ommit classification and child
      # taxa
      attr_accessor :response

      # Taxonomic status (e.g. `accepted name`, 'synonym') of the taxon;
      # optional, if ommitted, any match satisfying the other parameters
      # will be returned
      attr_accessor :status

      # Boolean; if ommitted, any match satisfying the other
      # parameters will be returned
      attr_accessor :extinct

      # Returns a new CatalogueOfLifeRequest for the CatalogueOfLige +id+.
      def self.by_id(id, content_type = :json)
        new(content_type) do |req|
          req.id = id
        end
      end

      # Returns a new TaxonRequest.
      def initialize(content_type = :json)
        @content_type = content_type
        @conn = Faraday.new 'http://www.catalogueoflife.org/' do |conn|
          conn.response @content_type, content_type: /\b#{@content_type.to_s}$/
          conn.adapter Faraday.default_adapter
        end
        @id = nil
        @name = nil
        @rank = nil
        @response = :full
        @status = nil
        @extinct = nil
        yield(self) if block_given?
      end

      #
      def get
        response = @conn.get do |req|
          req.url 'col/webservice?'
          req.params['format'] = content_type.to_s
          req.params['response'] = response
          req.params['id'] = id if id
          req.params['name'] = name if name
          req.params['rank'] = rank if rank
          req.params['extinct'] = extinct if extinct
        end
        response.body['results']
      end

      def to_s
        'Catalogue Of Life'
      end
    end
  end
end
