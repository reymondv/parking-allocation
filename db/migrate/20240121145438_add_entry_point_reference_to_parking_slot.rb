class AddEntryPointReferenceToParkingSlot < ActiveRecord::Migration[7.1]
  def change
    add_reference :parking_slots, :entry_point, foreign_key: true, null: true
  end
end
