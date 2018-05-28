# frozen_string_literal: true

module SPResource
  module Specify
    module Model
      RSpec.describe ViewSetObject do
        let :file do
          Pathname.new(Dir.pwd).join('spec', 'support',
                                     'viewsets', 'paleo.views.xml')
        end

        let :view_set_object do
          Collection.first(CollectionName: 'Test Collection').view_set
        end

        context 'when uploading a file' do
          it 'increments the version number' do
            v = view_set_object.Version
            expect { view_set_object.import(file) }
              .to change { view_set_object.Version }.from(v).to(v + 1)
          end

          it 'updates the modification timestamp' do
            expect { view_set_object.import(file) }
              .to change(view_set_object, :TimestampModified)
          end

          it 'increments the version number of the AppResourceDir' do
            v = view_set_object.app_resource_dir.Version
            expect { view_set_object.import(file) }
              .to change { view_set_object.app_resource_dir.Version }
                .from(v).to(v + 1)
          end

          it 'updates the modification timestamp of the AppResourceDir' do
            expect { view_set_object.import(file) }
              .to change(view_set_object.app_resource_dir, :TimestampModified)
          end

          it 'increments the version number of the AppResourceData' do
            v = view_set_object.app_resource_data.Version
            expect { view_set_object.import(file) }
              .to change { view_set_object.app_resource_data.Version }
                .from(v).to(v + 1)
          end

          it 'updates the modification timestamp of the AppResourceData' do
            expect { view_set_object.import(file) }
              .to change(view_set_object.app_resource_data, :TimestampModified)
          end

          it 'uploads the files content as a Sequel Blob' do
            view_set_object.app_resource_data.data = nil
            expect { view_set_object.import(file) }
              .to change { view_set_object.app_resource_data.data }
                .from(nil).to(Sequel.blob(File.read(file)))
          end
        end
      end
    end
  end
end
