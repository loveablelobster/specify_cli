# frozen_string_literal: true
TEST_BRANCH = 'SPSPEC/TestCollection/user/specuser'

# Tests for the
module Specify
  RSpec.describe BranchParser do
    context 'when creating instances from branch names' do
      let(:collection_level) { 'SPSPEC/TestCollection/collection' }
      let(:discipline_level) { 'SPSPEC/TestCollection/discipline' }
      let(:user_type_level) { 'SPSPEC/TestCollection/Manager' }
      let(:user_level) { 'SPSPEC/TestCollection/user/specuser' }

      let :config do
        Pathname.new(Dir.pwd).join('spec', 'support', 'db.yml')
      end

      it 'returns a hash for the collection level' do
        expect(described_class.new(collection_level).to_h)
          .to include database: 'SPSPEC',
                      collection: 'Test Collection',
                      level: :collection
      end

      it 'returns a hash for the discipline level' do
        expect(described_class.new(discipline_level).to_h)
          .to include database: 'SPSPEC',
                      collection: 'Test Collection',
                      level: :discipline
      end

      it 'returns a hash for the user type level' do
      	expect(described_class.new(user_type_level).to_h)
          .to include database: 'SPSPEC',
                      collection: 'Test Collection',
                      level: { user_type: :manager }
      end

      it 'returns a hash for the user level' do
        expect(described_class.new(user_level).to_h)
          .to include database: 'SPSPEC',
                      collection: 'Test Collection',
                      level: { user: 'specuser' }
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
