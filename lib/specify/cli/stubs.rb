# frozen_string_literal: true

def self.make_stubs(collection, cataloger, count)
  DB.transaction do
    count.times do
      puts count
      collection.add_collection_object(cataloger: cataloger)
    end
  end
end
