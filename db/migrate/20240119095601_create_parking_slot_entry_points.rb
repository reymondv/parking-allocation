class CreateParkingSlotEntryPoints < ActiveRecord::Migration[7.1]
  def change
    create_table :parking_slot_entry_points do |t|
      t.integer :distance, default: 1
      t.references :parking_slot, null: false, foreign_key: true
      t.references :entry_point, null: false, foreign_key: true

      t.timestamps
    end
  end
end
