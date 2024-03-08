class VehicleController < ApplicationController

  def index
    @parked_vehicle = Vehicle.parked_vehicles
  end

  def park
    feedback = { success: false, message: '' }

    entry_point = EntryPoint.find_by_name(params[:entry_point_name])

    unless entry_point
      feedback[:message] = 'Entry point not found.'
      render_feedback(feedback)
      return
    end

    parking_slot = ParkingSlot.nearest_available_slot(params[:entry_point_name], params[:size])

    unless parking_slot
      feedback[:message] = 'No available parking slots.'
      render_feedback(feedback)
      return
    end

    vehicle = Vehicle.find_or_initialize_by(plate_number: params[:plate_number].upcase)

    unless params[:plate_number].present?
      feedback[:message] = 'Invalid plate number. Must not be empty.'
      render_feedback(feedback)
      return
    end

    if vehicle.persisted? && vehicle.parking_slot.present?
      feedback[:message] = 'Vehicle is already parked.'
      render_feedback(feedback)
      return
    end

    vehicle.checkin_time = Time.parse(params[:checkin_time]) || Time.now
    vehicle.parking_slot = parking_slot

    if vehicle.save
      feedback[:success] = true
      ParkingSlot.find(parking_slot.id).update(occupied: true, entry_point: entry_point)
      feedback[:message] = "Vehicle #{vehicle.plate_number} was successfully parked at #{parking_slot.name}"
    else
      feedback[:message] = "Failed to park vehicle. #{vehicle.errors.full_messages.join(', ')}"
    end

    render_feedback(feedback)
  end

  def unpark
    feedback = { success: false, message: '' }

    @vehicle = Vehicle.find_by_plate_number(params[:plate_number].upcase)
    @previous_time = @vehicle.checkout_time
    unless @vehicle
      feedback[:message] = "No vehicle found with the given plate number #{params[:plate_number]}"
      render_feedback(feedback)
      return
    end

    @vehicle.update!(checkout_time: Time.parse(params[:checkout_time]))

    total_fee = calculate_fee
    
    @vehicle.parking_slot.update!(occupied: false, entry_point: nil)
    @vehicle.update!(parking_slot: nil)
    feedback[:success] = true
    feedback[:message] = "Vehicle #{@vehicle.plate_number} was unparked with a total fee of #{total_fee}"
    feedback[:total_fee] = total_fee
    feedback[:vehicle] = @vehicle
    feedback[:duration] = ((@vehicle.checkout_time - @vehicle.checkin_time) / 1.hour).ceil

    render_feedback(feedback)
  end

  private

  def calculate_fee
    exit_time = @vehicle.checkout_time
    entry_time = @vehicle.checkin_time
    exceeding_rate = { 0 => 20, 1 => 60, 2 => 100 }

    total_hours = ((exit_time - entry_time) / 1.hour).ceil

    # Continuous rate logic
    return 0 if (exit_time - entry_time) < 1.hour && @previous_time.present?

    # Flat rate for the first 3 hours
    fee = 40 * [total_hours, 3].min
    
    # Exceeding hourly rate based on parking slot size
    fee += exceeding_rate[@vehicle.parking_slot.size] * [total_hours - 3, 0].max
    # Apply 24-hour chunks
    # fee += 5000 * (total_hours / 24).floor 
    if total_hours > 3
      base_fee = 40
      exceeding_hours = total_hours - 3

      if exceeding_hours >= 24
        base_fee = (exceeding_hours / 24).floor * 5000
        exceeding_hours %= 24
      end

      fee = base_fee + exceeding_hours * exceeding_rate[@vehicle.parking_slot.size]
    end

    fee
  end

  def render_feedback(feedback)
    respond_to do |format|
      format.html
      format.json { render json: feedback }
    end
  end
end