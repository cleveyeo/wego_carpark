require 'rails_helper'

RSpec.describe CarparkParkingInformation, type: :model do
  describe 'default CarparkInformation details' do
    let(:carpark_parking_information) { create :carpark_parking_information }

    it 'should initialize carparkInformation with all details' do
      expect(carpark_parking_information.carpark_number).to eq("A89")
      expect(carpark_parking_information.total_lots).to eq(60)
      expect(carpark_parking_information.lots_available).to eq(20)
    end
  end
end
