class Vehicle < ApplicationRecord
  belongs_to :parking_slot, optional: true

  # after_save :update_parking_slot_occupation

  scope :with_free_parking, -> { joins(:parking_slot).merge(ParkingSlot.small_sizes) }

  def self.parked_vehicles
    joins(:parking_slot)
  end

  private

  def update_parking_slot_occupation
    return unless self.parking_slot

    self.parking_slot.update(occupied: true)
  end
end
