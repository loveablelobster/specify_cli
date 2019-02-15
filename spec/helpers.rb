# frozen_string_literal: true

require 'English'

# RSpec helpers
module Helpers
  def set_branch
    branch = `git branch --list #{TEST_BRANCH}`.chomp
    `git branch #{TEST_BRANCH}` if branch.empty?
    system("git checkout #{TEST_BRANCH}")
    e = "Error checking out #{TEST_BRANCH}
         there are probably uncommited changes on #{@origin}"
    raise e unless $CHILD_STATUS == 0
  end

  # TODO: make this more robust (find by Taxonomy by criteria)
  def spec_taxonomy
    Specify::Model::Taxonomy.first
  end

  def response(sym)
    yaml = Psych.load_file('spec/support/taxon_response.yaml').fetch sym
    Specify::CatalogueOfLife::TaxonResponse.new(yaml)
  end
end
