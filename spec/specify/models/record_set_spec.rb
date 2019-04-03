# frozen_string_literal: true

module Specify
  module Model
    RSpec.describe RecordSet do
      subject do
        described_class.create Name: 'Test Record Set',
                               user: user,
                               collection: collection
      end

      let(:collection) { Collection.first Code: 'SIP' }
      let(:user) { User.first Name: 'specuser' }

      it { p subject.highest_order_number }
    end
  end
end
