# frozen_string_literal: true

module Specify
  module Model
    #
    class Discipline < Sequel::Model(:discipline)
      many_to_one :division, key: :DivisionID

      one_to_many :app_resource_dirs,
                  class: 'Specify::Model::AppResourceDir',
                  key: :DisciplineID

      one_to_many :collecting_events, key: :DisciplineID
      one_to_many :localities, key: :DisciplineID

      many_to_many :auto_numbering_schemes,
                   left_key: :DisciplineID,
                   right_key: :AutoNumberingSchemeID,
                   join_table: :autonumsch_dsp

      many_to_one :taxonomy, key: :TaxonTreeDefID
      many_to_one :geography, key: :GeographyTreeDefID

      one_to_one :view_set_dir,
                 class: 'Specify::Model::AppResourceDir',
                 key: :DisciplineID do |ds|
                   ds.where(CollectionID: nil,
                            UserType: nil,
                            IsPersonal: false)
                 end

      def before_save
        self.Version += 1
        self.TimestampModified = Time.now
        super
      end

      # Returns a string containing a human-readable representation.
      def inspect
        "#{self} name: #{self.Name}"
      end

      # Returns the name of +self+.
      def name
        self.Name
      end

      # Returns the ViewSetObject.
      # The argument is only for ducktyping/overloading.
      def view_set(_collection = nil)
        view_set_dir&.view_set_object
      end
    end
  end
end
