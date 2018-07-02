# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe AppResourceData do
      let :file do
        Pathname.new(Dir.pwd).join('spec', 'support',
                                   'viewsets', 'paleo.views.xml')
      end

      let :app_resource_data do
        Collection.first(CollectionName: 'Test Collection')
                  .view_set.app_resource_data
      end

      context 'when uploading a file' do
        it 'increments the version number' do
          v = app_resource_data.Version
          expect { app_resource_data.import(file) }
            .to change { app_resource_data.Version }
              .from(v).to(v + 1)
        end

        it 'updates the modification timestamp' do
          expect { app_resource_data.import(file) }
            .to change(app_resource_data, :TimestampModified)
        end

        it 'uploads the files content as a Sequel Blob' do
          app_resource_data.data = nil
          expect { app_resource_data.import(file) }
            .to change { app_resource_data.data }
              .from(nil).to(Sequel.blob(File.read(file)))
        end
      end
    end
  end
end
