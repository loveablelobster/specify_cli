# frozen_string_literal: true

def self.make_stubs(collection, cataloger, count)
  stub_generator = Specify::StubGenerator.new(host: 'localhost',
                               database: 'SPSPEC',
                               collection: 'Test Collection',
                               config: file) do |stubs|
      stubs.cataloger = 'specmanager'
      stubs.preparation = prep
      stubs.accession = '2018-AA-001'
    end
  DB.transaction do
    stub_generator.create(count)
  end
  log stub_generator.generated
end
