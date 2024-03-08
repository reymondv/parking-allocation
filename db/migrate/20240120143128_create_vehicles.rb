class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.string :plate_number
      t.timestamp :checkin_time, default: Time.now
      t.timestamp :checkout_time
      t.references :parking_slot, null: true, foreign_key: true
      t.integer :total_fee, default: 0
      t.integer :total_hours, default: 0

      t.timestamps
    end
  end
end
