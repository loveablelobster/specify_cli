# frozen_string_literal: true

require_relative 'services/service'
require_relative 'services/stub_generator'
require_relative 'services/view_loader'

module Specify
  # TODO: describe me
  module Service
    ACCESSION_NOT_FOUND_ERROR = 'Accession not found: '
    USER_NOT_FOUND_ERROR = 'User not found: '
    LOCALITY_NOT_FOUND_ERROR = 'Locality not found: '
    TAXON_NOT_FOUND_ERROR = 'Taxon not found: '
    PREPTYPE_NOT_FOUND_ERROR = 'Preparation type not found: '
  end
end
