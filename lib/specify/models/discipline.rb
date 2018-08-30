# frozen_string_literal: true

module Specify
  module Model
    # Disciplines are the second lowest level of scope in a Specify::Database.
    #
    # A Discipline belongs to the a Specify::Model::Division.
    #
    # A Discipline has one or more instances of Specify::Model::Collection.
    #
    # A Discipline has one Specify::Model::Taxonomy, and one
    # Specify::Model::Geography (both of which can be shared with other
    # instances of Discipline).
    class Discipline < Sequel::Model(:discipline)
      include Updateable
      many_to_one :division,
                  key: :DivisionID
      one_to_many :app_resource_dirs,
                  class: 'Specify::Model::AppResourceDir',
                  key: :DisciplineID
      one_to_many :collecting_events,
                  key: :DisciplineID
      one_to_many :collections,
                  key: :DisciplineID
      one_to_many :localities,
                  key: :DisciplineID
      many_to_many :auto_numbering_schemes,
                   left_key: :DisciplineID,
                   right_key: :AutoNumberingSchemeID,
                   join_table: :autonumsch_dsp
      many_to_one :taxonomy,
                  key: :TaxonTreeDefID
      many_to_one :geography,
                  key: :GeographyTreeDefID
      one_to_one :view_set_dir,
                 class: 'Specify::Model::AppResourceDir',
                 key: :DisciplineID do |ds|
                   ds.where(CollectionID: nil,
                            UserType: nil,
                            IsPersonal: false)
                 end

      # Creates a string representation of +self+.
      def inspect
        "#{self} name: #{self.Name}"
      end

      # Returns a String that is the name of +self+.
      def name
        self.Name
      end

      # Returns the Specify::Model::ViewSetObject that belongs to +self+.
      # The +_collection+ argument will be discared and is only there to allow
      # intances to be used as a Specify::Service::ViewLoader#target.
      def view_set(_collection = nil)
        view_set_dir&.view_set_object
      end
    end
  end
end
