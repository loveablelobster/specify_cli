# frozen_string_literal: true

#
module Specify
  module CatalogueOfLife
    RSpec.describe TaxonResponse do
      let :astacidae do
        described_class.new(Psych.load_file('spec/support/taxon_response.yaml')
                                 .fetch :valid_family)
      end

      let :astacus do
        described_class.new(Psych.load_file('spec/support/taxon_response.yaml')
                                 .fetch :valid_genus)
      end

      let :astacus_astacus do
        described_class.new(Psych.load_file('spec/support/taxon_response.yaml')
                                 .fetch :valid_species)
      end

      let :astacus_edwardsi do
        described_class.new(Psych.load_file('spec/support/taxon_response.yaml')
                                 .fetch :extinct_species)
      end

      let :cancer_fimbriatus do
        described_class.new(Psych.load_file('spec/support/taxon_response.yaml')
                                 .fetch :synonym)
      end

      let :cancer_pagurus do
        described_class.new(Psych.load_file('spec/support/taxon_response.yaml')
                                 .fetch :accepted_with_synonyms)
      end

      context 'when calling a method not represented in #full_response' do
        subject(:no_method) { cancer_pagurus.no_such_key }

        it do
          expect { no_method }
            .to raise_error NoMethodError
        end
      end

      context 'when calling a method represented by a key in #full_response' do
        context 'when the key has a value' do
          subject { cancer_pagurus.author }

          it { is_expected.to eq 'Linnaeus, 1758' }
        end

        context 'when the key has no value' do
          subject { cancer_pagurus.subgenus }

          it { is_expected.to be_nil }
        end

        context 'when the value is empty' do
        	subject { cancer_pagurus.infraspecies }

          it { is_expected.to be_nil }
        end
      end

      describe '#accepted?' do
      	context 'when it is accepted' do
      		subject { cancer_pagurus.accepted? }

      		it { is_expected.to be_truthy }
      	end

      	context 'when it is not accepted' do
      		subject { cancer_fimbriatus.accepted? }

      		it { is_expected.to be_falsey }
      	end
      end

      describe '#children' do
      	context 'when it does not have children' do
      		subject { astacus_astacus.children }

      		it { is_expected.to be_empty }
      	end

      	context 'when it has children' do
      		subject(:children) { astacus.children }

      		it do
      			expect(children).to include '526387756aa5574c4879c6cc114248fd',
      			                            '8d133bcc525ea8e040d6858ed52625bd',
      			                            '386243cced4e42f3a15453c8ffad5dc4',
      			                            '54fe3bc380732201105cdde261a855d5',
      			                            'ed2a9af088ea52cc1907f2b552602a48',
      			                            '3d050be53ecfb6c9a33d8069532e43e4'
      		end
      	end
      end

      describe '#children?' do
      	context 'when it has children' do
          subject { astacus.children? }

          it { is_expected.to be_truthy }
      	end

      	context 'when it does not have children' do
          subject { astacus_astacus.children? }

          it { is_expected.to be_falsey }
      	end
      end

      describe '#extinct?' do
      	context 'when it is extant)' do
          subject { astacus_astacus.extinct? }

          it { is_expected.to be_falsey }
      	end

        context 'when it is extinct' do
        	subject { astacus_edwardsi.extinct? }

        	it { is_expected.to be_truthy }
        end

      	context 'when it is a synonym' do
      		subject { cancer_fimbriatus.extinct? }

      		it { is_expected.to be_nil }
      	end
      end

      describe '#name' do
        context 'when it is an infraspecies' do
        	it 'should be the infraspecific epithet'
        end

        context 'when it is a species' do
        	subject { astacus_astacus.name }

        	it { is_expected.to eq 'astacus' }
        end

        context 'when it is a subgenus' do
        	it 'should be the subgenus name'
        end

        context 'when it is a genus' do
          subject { astacus.name }

          it { is_expected.to eq 'Astacus' }
        end
      end

      describe '#parent' do
        context 'when it is the root (parent not parsed)' do
        	it 'returns a the last item in the classification'
        	# or not! what if that just parses all to the root?
        end

        context 'when it is below the root (parent parsed)' do
        	before { astacus_astacus.parent = astacus }

        	it 'is a TaxonResponse or a Model::Taxon'
        end
      end

      describe '#synonyms?' do
      	context 'when it has no synonyms attribute' do
      		subject { astacus.synonyms? }

      		it { is_expected.to be_nil }
      	end

      	context 'when it has no synonyms' do
      		subject { astacus_astacus.synonyms? }

      		it { is_expected.to be_falsey }
      	end

      	context 'when it has synonyms' do
      		subject { cancer_pagurus.synonyms? }

      		it { is_expected.to be_truthy }
      	end
      end

      describe '#synonyms' do
      	context 'when it has no synonyms' do
      		subject { astacus_astacus.synonyms }

      		it { is_expected.to be_empty }
      	end

      	context 'when it has synonyms' do
      		subject(:synonyms) { cancer_pagurus.synonyms }

      		it do
      			expect(synonyms).to include 'd81941a10d07fcc621073de9cdefca96',
      			                            '4a6de56affa3de0e027145d2d7136f2a',
      			                            'cc57308ba2f409c765bbdaedcbaa1f78'
      		end
      	end
      end
    end
  end
end
