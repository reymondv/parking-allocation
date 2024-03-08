class ParkingAllocationSystemController < ApplicationController
  before_action :initialize_parking_system, only: [:index, :parking_system]

  def index
    @parking_system = @@parking_system
  end

  def parking_system
    entry_points = ['A', 'B', 'C'] #Initialize your entry_points here 
    parking_slots = [[1, 4, 5], [3, 2, 3], [2, 5, 4], [3, 4, 1], [1, 2, 3]] #Initialize your parking_slots here 
    slot_sizes = [0, 1, 2, 2, 0] #Initialize your slot_sizes here 

    @@parking_system = ParkingAllocationSystem.new(entry_points, parking_slots, slot_sizes)

    respond_to do |format|
      format.json { render json: @@parking_system }
    end
  end

  def park_vehicle
    park_vehicle = @@parking_system.park_vehicle(park_params)
    
    respond_to do |format|
      format.json { render json: @@parking_system }
    end
  end

  def unpark_vehicle
    unpark_vehicle = @@parking_system.unpark_vehicle(unpark_params)

    respond_to do |format|
      format.json { render json: @@parking_system }
    end
  end

  private

  def initialize_parking_system
    entry_points = ['A', 'B', 'C'] #Initialize your entry_points here 
    parking_slots = [[1, 4, 5], [3, 2, 3], [2, 5, 4], [3, 4, 1], [1, 2, 3]] #Initialize your parking_slots here 
    slot_sizes = [0, 1, 2, 2, 0] #Initialize your slot_sizes here 

    @@parking_system ||= ParkingAllocationSystem.new(entry_points, parking_slots, slot_sizes)
  end

  def park_params
    params.require(:parking_allocation_system).permit(:vehicle_id, :vehicle_type, :entry_point, :previous_time).merge(entry_time: Time.now)
  end

  def unpark_params
    params.require(:parking_allocation_system).permit(:vehicle_id, :exit_time)
  end
end
