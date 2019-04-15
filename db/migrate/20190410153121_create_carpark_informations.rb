class CreateCarparkInformations < ActiveRecord::Migration[5.2]
  def change
    create_table :carpark_informations do |t|
      t.string :car_park_no
      t.string :address
      t.string :x_coord
      t.string :y_coord

      t.timestamps
    end
  end
end
