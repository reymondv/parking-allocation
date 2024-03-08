class ParkingSlot < ApplicationRecord
  has_many :parking_slot_entry_points
  belongs_to :entry_point, optional: true
  has_many :entry_points, through: :parking_slot_entry_points
  has_one :vehicle

  scope :occupied, -> { where(occupied: true) }
  scope :free, -> { where(occupied: false) }

  def self.nearest_available_slot(entry_point, size)
    find_by_sql(["SELECT ps.id, ps.name, min(pspe.distance) as distance, ps.occupied, ps.size, pspe.entry_point_id, ep.name as entry_point_name FROM parking_slots ps
    INNER JOIN parking_slot_entry_points pspe ON ps.id = pspe.parking_slot_id
    INNER JOIN entry_points ep ON pspe.entry_point_id = ep.id
    WHERE ps.occupied = false
    AND ep.name = :entry_point
    AND ps.size >= :size
    GROUP BY ps.id
    ORDER BY distance", { entry_point: entry_point, size: size }]).first
  end

  def self.free_slots
    select(:id, :name, :size, :occupied).free
  end

  def self.occupied_slots_with_vehicles
    joins(:entry_point, :vehicle ).select(parking_slots: { id: :id, name: :name, size: :size, occupied: :occupied }, vehicle: { id: :vehicle_id, plate_number: :plate_number, checkin_time: :checkin_time, checkout_time: :checkout_time }, entry_points: { name: :entry_point_name })
  end
end
