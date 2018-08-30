# frozen_string_literal: true

Sequel.extension :inflector

Sequel.inflections do |inflect|
  inflect.irregular 'taxon', 'taxa'
end

String.inflections do |inflect|
  inflect.irregular 'taxon', 'taxa'
end

require_relative 'models/tree_queryable'
require_relative 'models/createable'
require_relative 'models/updateable'
require_relative 'models/accession'
require_relative 'models/agent'
require_relative 'models/app_resource_data'
require_relative 'models/app_resource_dir'
require_relative 'models/auto_numbering_scheme'
require_relative 'models/collecting_event'
require_relative 'models/collection'
require_relative 'models/collection_object'
require_relative 'models/determination'
require_relative 'models/discipline'
require_relative 'models/division'
require_relative 'models/geography'
require_relative 'models/institution'
require_relative 'models/locality'
require_relative 'models/preparation'
require_relative 'models/preparation_type'
require_relative 'models/record_set'
require_relative 'models/record_set_item'
require_relative 'models/taxonomy'
require_relative 'models/user'
require_relative 'models/view_set_object'

module Specify
  # Model contains Sequel::Model classes for the _Specify_ schema.
  module Model
    AMBIGUOUS_MATCH_ERROR = 'Ambiguous results during search'
  end
end
