# frozen_string_literal: true

# Tests for the
module SpResource
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

    context 'when fetching the git branch' do
      before :all do
        b_name = 'SPSPEC/TestCollection/user/specuser'
      	branch = `git branch --list #{b_name}`.chomp
      	/(\*) (#{b_name})/.match(branch) do |m|
      	  break if m[1] # current branch
      	  system("git checkout #{b_name}")
      	  unless $? == 0
      	    puts "Error checking out #{m[2]}
      	          there are probably uncommited changes on #{branch}"
      	  end
      	end
      end

    	it 'parses a name from the current branch' do
        p described_class.current_branch
    	end

    	it 'exits with an error message if the branch name is not parsable'
    end
  end
end
