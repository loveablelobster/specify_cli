# frozen_string_literal: true
TEST_BRANCH = 'SPSPEC/TestCollection/user/specuser'

# Tests for the
module Specify
  RSpec.describe BranchParser do


    context 'when creating instances from branch names' do
      let :config do
        Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      let(:path) { 'sp_resource' }

      let(:collection_level) { 'SPSPEC/TestCollection/collection' }
      let(:discipline_level) { 'SPSPEC/TestCollection/discipline' }
      let(:user_type_level) { 'SPSPEC/TestCollection/Manager' }
      let(:user_level) { 'SPSPEC/TestCollection/user/specuser' }

      let :config do
        Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      context 'when collection' do
        subject { described_class.new path, collection_level, config }

        it do
          is_expected.to have_attributes host: 'localhost',
                                         database: 'SPSPEC',
        	                               collection: 'Test Collection',
        	                               level: :collection
        end
      end

      context 'when discipline' do
        subject { described_class.new path, discipline_level, config }

        it do
          is_expected.to have_attributes host: 'localhost',
                                         database: 'SPSPEC',
        	                               collection: 'Test Collection',
        	                               level: :discipline
        end
      end

      context 'when user type' do
        subject { described_class.new path, user_type_level, config }

        it do
          is_expected.to have_attributes host: 'localhost',
                                         database: 'SPSPEC',
        	                               collection: 'Test Collection',
        	                               level: { user_type: :manager }
        end
      end

      context 'when user' do
        subject { described_class.new path, user_level, config }

        it do
          is_expected.to have_attributes host: 'localhost',
                                         database: 'SPSPEC',
        	                               collection: 'Test Collection',
        	                               level: { user: 'specuser' }
        end
      end
    end

    context 'when fetching the git branch', skip: true do
      before :all do
      	@origin = `#{GIT_CURRENT_BRANCH}`.chomp
      	break if TEST_BRANCH == @origin
        set_branch
      end

    	it 'parses a name from the current branch' do
        expect(described_class.current_branch)
          .to have_attributes database: 'SPSPEC',
                              collection: 'Test Collection',
                              level: { user: 'specuser' }
    	end

    	it 'exits with an error message if the branch name is not parsable' do
    		expect { described_class.new('master') }
    		  .to raise_error ArgumentError, BRANCH_ERROR + 'master'
    	end

    	after :all do
    	  system("git checkout #{@origin}")
    	end
    end
  end
end
