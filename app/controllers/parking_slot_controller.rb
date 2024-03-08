class ParkingSlotController < ApplicationController

  def index
  end

  def parking_spaces
    @free_slots = ParkingSlot.free_slots
    @occupied_slots = ParkingSlot.occupied_slots_with_vehicles
    
    respond_to do |format|
      format.html 
      format.json { render json: { free_slots: @free_slots, occupied_slots: @occupied_slots } }
    end
  end

  def free_slots
    @free_slots = ParkingSlot.free_slots
    
    respond_to do |format|
      format.html 
      format.json { render json: @free_slots }
    end
  end

  def occupied_slots
    @occupied_slots = ParkingSlot.occupied_slots_with_vehicles

    respond_to do |format|
      format.html 
      format.json { render json: @occupied_slots }
    end
  end
end