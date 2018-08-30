# frozen_string_literal: true

module Specify
  module Model
    # CollectionObjects represent the organisms or artifeacts collected, but
    # not the physical items stored in a collection (see
    # Specify::Model::Preparation).
    #
    # A CollectionObject belongs to Specify::Model::Collection and can have one
    # or many #preparations (instances of Specify::Model::Preparation).
    #
    # A CollectionObject belongs to a #collecting_event (an instance of
    # Specify::Model::CollectingEvent), that holds information about when,
    # where, how, and by whom it was collected.
    #
    # A CollectionObject can have one or many #determinations (instances of
    # Specify::Model::Determination), which represent opinions on what
    # Specify::Model::Taxon the CollectionObject represents.
    class CollectionObject < Sequel::Model(:collectionobject)
      include Createable
      include Updateable

      many_to_one :collection,
                  key: :CollectionID
      many_to_one :collection_member,
                  class: 'Specify::Model::Collection',
                  key: :CollectionMemberID
      many_to_one :accession,
                  key: :AccessionID
      many_to_one :cataloger,
                  class: 'Specify::Model::Agent',
                  key: :CatalogerID
      many_to_one :collecting_event,
                  key: :CollectingEventID
      one_to_many :determinations,
                  key: :CollectionObjectID
      one_to_many :preparations,
                  key: :CollectionObjectID
      many_to_one :created_by,
                  class: 'Specify::Model::Agent',
                  key: :CreatedByAgentID
      many_to_one :modified_by,
                  class: 'Specify::Model::Agent',
                  key: :ModifiedByAgentID

      # Returns the #catalog_number of +self+ if it has one. If not, returns
      # the next available catalog number in the
      # Specify::Model::AutoNumberingScheme in the Specify::Model::Collection
      # +self+ belongs to.
      def auto_number
        catalog_number || collection.auto_numbering_scheme.increment
      end

      # Sequel hook that assigns a newly created records to a
      # Specify::Model::Collection (the collection is referenced twice; through
      # #collection and #collection_member; the #collection will be
      # automatically set if the records is created through the
      # Specify::Model::Collecion#add_collection_object association method; the
      # hook will set the other reference).
      #
      # Assigns the next available #catalog_number in the collection.
      #
      # Sets the _CatalogedDate_ attribute and assigns a Specify::Model::Agent
      # as the #cataloger.
      #
      # Assigns a GUID.
      #
      # If CollectionObjects in #collection can not share colecting events
      # (there is one Specify::Model::CollectingEvent for every
      # CollectionObject), this will create a new, empty,
      # Specify::Model::CollectingEvent for the record.
      def before_create
        self.collection_member = collection
        self[:CatalogNumber] = auto_number
        self[:CatalogedDate] = Date.today
        self[:CatalogedDatePrecision] = 1
        self[:GUID] = SecureRandom.uuid
        self.collecting_event = embed_collecting_event
        super
      end

      # Returns a String that is the catalog number of +self+.
      def catalog_number
        self[:CatalogNumber]
      end

      # Returns a Date that is the date +self+ was cataloged (typically when
      # it was registered in the database).
      def cataloged_date
        self[:CatalogedDate]
      end

      # If CollectionObjects in #collection can not share colecting events
      # (there is one Specify::Model::CollectingEvent for every
      # CollectionObject), this will create a new, empty,
      # Specify::Model::CollectingEvent for the record.
      def embed_collecting_event
        return unless collection.embedded_collecting_event?
        CollectingEvent.create discipline: collection.discipline
      end

      # Updates the associated Specify::Model::CollectingEvent with +vals+
      # (a Hash).
      def geo_locate(vals)
        collecting_event.update(vals)
        collecting_event.save
      end

      # Creates a new Specify::Model::Determination for +self+ with +vals+
      # (a Hash).
      def identify(vals)
        add_determination vals
        self.save
      end

      # Creates a string representation of +self+.
      def inspect
        to_s
      end

      # Creates a string representation of +self+.
      def to_s
        "#{catalog_number} cataloged by #{cataloger}, #{cataloged_date}"
      end
    end
  end
end
