require 'spec_helper'

RSpec.describe Order do
  describe Order.wombat_order_hash(Factories.order) do
    it { expect(subject['status']).to eq 'Complete' }
  end
end
