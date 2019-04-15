class CreateCarparkParkingInformations < ActiveRecord::Migration[5.2]
  def change
    create_table :carpark_parking_informations do |t|
      t.string :carpark_number
      t.integer :total_lots
      t.integer :lots_available

      t.timestamps
    end
  end
end
