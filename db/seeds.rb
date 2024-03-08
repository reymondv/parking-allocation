# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

entry_points = ['A', 'B', 'C'] # Entry points
parking_slots = [[1, 4, 5], [3, 2, 3], [2, 5, 4], [3, 4, 1], [1, 2, 3]] # Parking slots 
slot_sizes = [0, 1, 2, 2, 0] # Parking slot sizes

# entry_points.each do |entry_point|
#   EntryPoint.find_or_create_by!(name: entry_point)
# end

parking_slots.each_with_index do |parking_slot, index|
  ps = ParkingSlot.find_or_create_by!(name: "P#{index+1}", size: slot_sizes[index])
  parking_slot.each_with_index do |entry_point_distance, index|
    ep = EntryPoint.find_or_create_by!(name: entry_points[index])
    ParkingSlotEntryPoint.find_or_create_by!(parking_slot_id: ps.id, entry_point_id:  ep.id, distance: entry_point_distance)
  end
end