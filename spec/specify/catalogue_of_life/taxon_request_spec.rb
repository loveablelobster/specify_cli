# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonRequest do
      let :crayfish do
        described_class.new(:json) do |req|
          req.name = 'Astacus astacus'
          req.rank = 'species'
        end
      end

      let :ambiguous_request do
        described_class.new(:json) do |req|
          req.name = 'Astacus'
        end
      end

      describe '.by_id' do
        subject :request do
           described_class.by_id '67b8da25464f297cf738a3712bc7eaa0'
        end

        it do
          expect(request).to be_a(described_class)
            .and have_attributes id: '67b8da25464f297cf738a3712bc7eaa0',
                                 content_type: :json,
                                 response_type: :full
        end
      end

      describe '#connection' do
        subject(:connection) { crayfish.connection }

        it { is_expected.to be_a Faraday::Connection }
      end

      describe '#get' do
        subject(:sent_requet) { crayfish.get }

        it { expect(sent_requet).to be_a(Faraday::Response) }
      end

      describe '#params' do
        subject(:params) { crayfish.params }

        it do
          expect(params).to include 'format' => 'json',
                                    'response' => 'full',
                                    'name' => 'Astacus astacus',
                                    'rank' => 'species'
        end
      end

      describe '#rank=' do
        subject(:assign_subspecies) { crayfish.rank = 'Genus' }

        it do
          expect { assign_subspecies }
            .to change(crayfish, :rank)
            .from(TaxonRank.species)
            .to TaxonRank.genus
        end
      end

      describe '#response' do
        subject { crayfish.response }

        context 'when #get has been called' do
          before { crayfish.get }

          it { is_expected.to be_a Faraday::Response }
        end

        context 'when #get has not been called' do
          it { is_expected.to be_nil }
        end
      end

      describe '#taxon_response' do
        context 'when request returns unambigous results' do
          subject { crayfish.taxon_response }

          it { is_expected.to be_a TaxonResponse }
        end

        context 'when request returns multiple results' do
          subject(:ambiguous_results) { ambiguous_request.taxon_response }

          it do
            expect { ambiguous_results }
              .to raise_error RuntimeError, ResponseError::AMBIGUOUS_RESULTS
          end
        end
      end

      describe '#to_s' do
        subject(:req_string) { crayfish.to_s }

        it do
          expect(req_string)
            .to eq 'http://www.catalogueoflife.org/col/webservice?'\
                   'format=json&response=full'\
                   '&name=Astacus%20astacus&rank=species'
        end
      end

      describe '#to_uri' do
        subject(:req_uri) { crayfish.to_uri}

        it do
          expect(req_uri).to be_a(URI) &
            have_attributes(host: 'www.catalogueoflife.org',
                            path: '/col/webservice',
                            query: 'format=json&response=full&'\
                                   'name=Astacus%20astacus&rank=species')
        end
      end

      describe '#uri_query' do
        subject(:query) { crayfish.uri_query }

        it do
          expect(query)
            .to eq '?format=json&response=full&'\
                   'name=Astacus%20astacus&rank=species'
        end
      end
    end
  end
end
