# frozen_string_literal: true

module Specify
  module Model
    # AdministrativeDivision is the _rank_ class for the
    # Specify::Model::Geography _tree_. An AdministrativeDivision holds
    # information about a formal political subdivison in a <em>geographic
    # tree</em>.
    #
    # A AdministrativeDivision has a _parent_ (another instance of
    # AdministrativeDivision) unless it is the root rank of the _tree_ and can
    # have one _child_ (another instance of AdministrativeDivision).
    class AdministrativeDivision < Sequel::Model(:geographytreedefitem)
      include Updateable

      many_to_one :geography,
                  key: :GeographyTreeDefID
      one_to_many :geographic_names,
                  key: :GeographyTreeDefItemID
      one_to_one :child,
                 class: self,
                 key: :ParentItemID
      many_to_one :parent, class: self,
                  key: :ParentItemID

      # Returns a String with the name of the formal political subdivision.
      def name
        self.Name
      end
    end
  end
end
