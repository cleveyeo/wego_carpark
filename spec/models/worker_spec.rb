require 'rails_helper'

RSpec.describe Worker, type: :model do

  describe 'default worker details' do
    let(:worker) { create :worker }

    it 'should initialize worker with name and age' do
      expect(worker.name).to eq("MyString")
    end
  end

end
