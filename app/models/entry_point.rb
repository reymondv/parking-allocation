class EntryPoint < ApplicationRecord
  has_many :parking_slot_entry_points
  has_many :parking_slots
  has_many :parking_slots, through: :parking_slot_entry_points

  def self.all_entry_points
    select(:id, :name).all.map(&:name)
  end
end
