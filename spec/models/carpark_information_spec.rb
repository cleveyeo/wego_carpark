require 'rails_helper'

RSpec.describe CarparkInformation, type: :model do
  describe 'default CarparkInformation details' do
    let(:carparkInformation) { create :carparkInformation }

    it 'should initialize carparkInformation with all details' do
      expect(carparkInformation.car_park_no).to eq("123")
      expect(carparkInformation.address).to eq("Bedok")
      expect(carparkInformation.x_coord).to eq("34.786543")
      expect(carparkInformation.y_coord).to eq("76.098764")
    end
  end
end
