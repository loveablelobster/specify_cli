# frozen_string_literal: true

def self.make_stubs(collection, cataloger, count)
  DB.transaction do
    Specify::StubGenerator.new(host: 'localhost',
                               database: 'SPSPEC',
                               collection: 'Test Collection',
                               config: file) do |stubs|
      stubs.cataloger = 'specmanager'
      stubs.preparation = prep
      stubs.accession = '2018-AA-001'
    end
  end
end
