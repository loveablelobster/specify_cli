# frozen_string_literal: true

module Specify
  module CatalogueOfLife
    # TaxonRequests represent a HTTP GET request to the service.
    class TaxonRequest
      include ERB::Util

      # The format for the response, +:json+ or +:xml+.
      attr_accessor :content_type

      # CatalogueOfLife id of the taxon.
      attr_accessor :id

      # Name of the taxon to search for.
      attr_accessor :name

      # Rank of the taxon to search for (can be multiple).
      # if empty, all matches within any rank will be returned
      attr_reader :rank

      # A Farday::Response from sending from the service. Gets automatically
      # set when calling #get.
      attr_accessor :response

      # :full (default) or :terse. :terse will ommit classification and child
      # taxa
      attr_accessor :response_type

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
        @id = nil
        @name = nil
        @rank = nil
        @response_type = :full
        @status = nil
        @extinct = nil
        @response = nil
        yield(self) if block_given?
      end

      # The Faraday::Connection for the request.
      def connection
        Faraday.new URL do |conn|
          conn.response @content_type, content_type: /\b#{@content_type.to_s}$/
          conn.adapter Faraday.default_adapter
        end
      end

      # Sends a HTTP GET request to the service.
      # Returns a Faraday::Response.
      def get
        self.response = connection.get do |req|
          req.url API_ROUTE
          params.each { |key, value| req.params[key] = value }
        end
      end

      # Returns a Hash with the URL parameter.
      def params
        {
          'format' => content_type.to_s,
          'response' => response_type.to_s,
          'id' => id,
          'name' => name,
          'rank' => rank.to_s,
          'extinct' => extinct
        }.compact
      end

      # Setter for the @rank attribute. Will assign a
      # CatalogueOfLife::Rank.
      def rank=(name)
        @rank = Rank.new(name)
      end

      # Returns a CatalogueOfLife::Taxon for the request.
      # Will raise a MultipleResultsError
      def taxon_response
        results = response&.body&.fetch('results') || get.body['results']
        raise ResponseError::AMBIGUOUS_RESULTS if results.size > 1

        raise ResponseError::NOT_FOUND if results.empty?

        Taxon.new results.first
      end

      # Returns a String representation of +self+.
      def to_s
        URL + API_ROUTE + uri_query
      end

      # Returns a URI object for the request.
      def to_uri
        URI(to_s)
      end

      # Returns the query part of the URI for the HTTP request.
      def uri_query
        params.compact.reduce('?') do |memo, param|
          memo += '&' unless memo == '?'
          memo + param[0] + '=' + url_encode(param[1])
        end
      end
    end
  end
end
