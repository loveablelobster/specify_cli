# frozen_string_literal: true

module Specify
  module Model
    # Preparations are the physical (or virtual) represenatations of a
    # Specify::Model::CollectionObject in a Speciy::Model::Collection.
    #
    # Collection objects represent the organisms or artifacts collected, the
    # preparations are items derived from that organism or artifacts which are
    # the actual units in a collections physical storage. In an ornithological
    # collection, for example, the collection object will be the bird collected,
    # preparations will be the skin, the skeleton, or any other physcial (or
    # virtual derivatives).
    #
    # A preparation belongs to a Specify::Model::PreparationType, that
    # provides a controlled vocabulary for available types of preparations (e.g.
    # skin, skeletons, EtOH).
    #
    # A preparation has a #count, that is the number of items in a preparation.
    # If, for example, the preparation is a jar of shrimps in ethanol, the
    # preparation_type could be `EtOH`, and if there are 10 shrimps in the jar,
    # the #count would be +10+.
    class Preparation < Sequel::Model(:preparation)
      include Createable
      include Updateable

      many_to_one :collection_object,
                  key: :CollectionObjectID
      many_to_one :collection,
                  class: 'Specify::Model::Collection',
                  key: :CollectionMemberID
      many_to_one :preparation_type,
                  key: :PrepTypeID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Sequel hook that assigns a GUID.
      def before_create
        self[:GUID] = SecureRandom.uuid
        super
      end

      # Returns the number of items in a preparation.
      def count
        self.CountAmt
      end
    end
  end
end
