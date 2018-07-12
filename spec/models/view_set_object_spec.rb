# frozen_string_literal: true

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

      describe '#import(views_file)' do
        subject(:view_set_import) { view_set_object.import(file) }

        before { view_set_object.app_resource_data.data = nil }

        it do
          expect { view_set_import }
            .to change(view_set_object, :Version)
            .by 1
        end

        it do
          just_before = Time.now
          expect { view_set_import }
            .to change(view_set_object, :TimestampModified)
            .from(a_value <= just_before)
            .to a_value >= just_before
        end

        it do
          expect { view_set_import }
            .to change { view_set_object.app_resource_dir.Version }
            .by 1
        end

        it do
          just_before = Time.now
          expect { view_set_import }
            .to change(view_set_object.app_resource_dir, :TimestampModified)
            .from(a_value <= just_before)
            .to a_value >= just_before
        end

        it do
          expect { view_set_import }
            .to change { view_set_object.app_resource_data.Version }
            .by 1
        end

        it do
          just_before = Time.now
          expect { view_set_import }
            .to change(view_set_object.app_resource_data, :TimestampModified)
            .from(a_value <= just_before)
            .to a_value >= just_before
        end

        it do
          expect { view_set_import }
            .to change { view_set_object.app_resource_data.data }
            .from(nil).to(Sequel.blob(File.read(file)))
        end
      end
    end
  end
end
