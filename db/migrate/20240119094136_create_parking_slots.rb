class CreateParkingSlots < ActiveRecord::Migration[7.1]
  def change
    create_table :parking_slots do |t|
      t.string :name, null: false
      t.integer :size, default: 0
      t.boolean :occupied, default: false
  
      t.timestamps
    end
  end
end
