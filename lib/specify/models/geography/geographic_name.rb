# frozen_string_literal: true

module Specify
  module Model
    # GeographicName is the _item_ class for the Specify::Model::Geography
    # _tree_. A GeographicName holds information about the items to be
    # classified, i.e. concepts of geographic names. Each GeographicName belongs
    # to a Specify::Model::AdministrativeDivision, that represents the formal
    # political subdivision in a geography.
    #
    # A GeographicName has a _parent_ (another instance of GeographicName)
    # unless it is the root geographic name of the _tree_ and can have
    # _children_ (other instances of GeographicName).
    class GeographicName < Sequel::Model(:geography)
      include Updateable

      many_to_one :geography,
                  key: :GeographyTreeDefID
      many_to_one :rank,
                  class: 'Specify::Model::AdministrativeDivision',
                  key: :GeographyTreeDefItemID
      many_to_one :parent,
                  class: self,
                  key: :ParentID
      many_to_one :accepted_name,
                  class: self,
                  key: :AcceptedID
      one_to_many :children,
                  class: self,
                  key: :ParentID
      one_to_many :synonyms,
                  class: self,
                  key: :AcceptedID
      one_to_many :localities,
                  key: :GeographyID

      # Assigns new instances that are created from a
      # Specify::Model::AdministrativeDivision to the administrative division's
      # Specify::Model::Geography. Sets _Version_, timestamp for
      # creation, and a GUID for the record.
      def before_create
        self.geography = rank&.geography ||
                         parent.rank&.geography
        self[:Version] = 0
        self[:TimestampCreated] = Time.now
        self[:GUID] = SecureRandom.uuid
        super
      end

      # Returns +true+ if +self+ has _children_.
      def children?
        !children.empty?
      end

      # Creates a string representation of +self+.
      def inspect
        "id: #{self.GeographyID}; Full Name: '#{self.FullName}'"
      end

      # Returns a String with the geographic name.
      def name
        self[:Name]
      end
    end
  end
end
