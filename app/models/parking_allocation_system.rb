# app/models/parking_system.rb
class ParkingAllocationSystem
  attr_accessor :entry_points, :parking_slots, :slot_sizes, :parked_vehicles
  attr_reader :errors

  def initialize(entry_points, parking_slots, slot_sizes)
    @errors = []
    @messages = []
    @entry_points = entry_points
    @parking_slots = parking_slots
    @slot_sizes = identify_slot_sizes(slot_sizes)
    @parked_vehicles = Hash.new { |hash, key| hash[key] = {} }
    
  end

  # To park a vehicle by providing vehicle_id, vehicle_type, entry_pointt, entry_time, and previous_time to recognise continous rate
  def park_vehicle(params)
    vehicle_id = params[:vehicle_id]
    vehicle_type = params[:vehicle_type]
    entry_point = params[:entry_point]
    entry_time = params[:entry_time]
    previous_time = params[:previous_time] ? Time.parse(params[:previous_time]) : nil
    # Return if entry point is not equal to the initialized entry points
    @messages = []
    return @errors << "Invalid entry points provided." unless entry_points.include?(entry_point)

    is_vehicle_id_parked = parked_vehicles.any? do |_, inner_hash|
      inner_hash.any? { |key_inner, key_outer| key_outer[:vehicle_id] == vehicle_id.upcase }
    end

    return @errors << "Entry time is less than previous time" if previous_time && entry_time < previous_time

    return @errors << "Please input a valid vehicle number. Vehicle number must not be blank." if vehicle_id.blank?

    return @errors << "Vehicle ID is currently parked in a parking spot." if is_vehicle_id_parked 

    # Check for available slots for the current vehicle type
    available_slots = find_available_slots(vehicle_type)

    # Return if there are no available parking slots 
    
    return @errors << "No available slot for #{vehicle_type} vehicles." if available_slots.empty?

    # Get the closest available slot from the entry points
    closest_slot = available_slots.min_by { |slot| parking_slots[slot][entry_points.index(entry_point)] }

    # Remove slot from slot_sizes array and get the slot size of the parking slot
    slot_type = ''
    slot_sizes.each_key do |key|
      slot_type = key if slot_sizes[key].include?(closest_slot)
      slot_sizes[key].reject! { |value| value == closest_slot }
    end

    # Insert vehicle_id, entry_point, entry_time, slot_type info to the hash of parked vehicles
    parked_vehicles[entry_point][closest_slot] = { vehicle_id: vehicle_id.upcase, entry_point: entry_point, entry_time: entry_time, slot_type: slot_type, previous_time: previous_time, vehicle_type: vehicle_type }

    @errors = []
    @messages = {closest_slot: closest_slot, entry_point: entry_point, entry_time: entry_time, vehicle_type: vehicle_type, slot_type: slot_type, vehicle_id: vehicle_id.upcase}
    parked_vehicles
  end

  # To unpark a vehicle by providing vehicle_id and exit_time
  def unpark_vehicle(params)
    vehicle_id = params[:vehicle_id]
    exit_time = Time.parse(params[:exit_time])
    @messages = []
    return unless parked_vehicles.any? { |entry_point| entry_point.present? }

    parked_vehicles.each do |key, value|
      value.each do |key, value|
        slot = key
        # { vehicle_id, entry_point, entry_time, slot_type } = value

        if value[:vehicle_id].downcase == vehicle_id.downcase
          if value[:previous_time].present? && exit_time < value[:previous_time]
            @errors << "Date mismatch with previous and exit time." 
            return 
          end
          entry_time = value[:previous_time].present? ? value[:previous_time] : value[:entry_time]
          duration = ((exit_time - entry_time) / 3600).ceil
          total_fee = calculate_fee(value[:slot_type], value[:previous_time], value[:entry_time], duration)

          parked_vehicles[value[:entry_point]].delete(slot)

          parked_vehicles.delete(value[:entry_point]) unless parked_vehicles[value[:entry_point]].present?
          slot_sizes[value[:slot_type]] << slot

          puts "Vehicle unparked from slot #{slot}."
          puts "Total fee: #{total_fee} pesos."
          @errors = []
          @messages = { unparked_from: slot, entry_point: value[:entry_point], exit_time: exit_time, duration: duration, vehicle_type: value[:vehicle_type], vehicle_id: value[:vehicle_id].upcase, total_fee: total_fee, slot_type: value[:slot_type] }  
          return
        end
      end
    end

    @errors << "No matching vehicle found at the specified entry point."
  end

  private

  def find_available_slots(vehicle_type)
    allowed_slots = []
    slot_sizes.each do |size, slots|
      allowed_slots.concat(slots) if size == vehicle_type || (size == 'M' && vehicle_type == 'S') || (size == 'L' && (vehicle_type == 'S' || vehicle_type == 'M')) && parked_vehicles
    end
    allowed_slots
  end

  def calculate_fee(vehicle_type, previous_time, entry_time, duration)
    flat_rate = 40
    exceeding_rate = { 'S' => 20, 'M' => 60, 'L' => 100 }
    
    if previous_time.present?
      base_fee = 0
      duration -= 1
      if entry_time - previous_time <= 1.hour
        return base_fee
      end
      
      if duration >= 24
        base_fee += (duration / 24).floor * 5000
        duration %= 24
      end
      
      base_fee + duration * exceeding_rate[vehicle_type]
    elsif duration <= 3
      flat_rate
    else
      base_fee = flat_rate
      exceeding_hours = duration - 3

      if exceeding_hours >= 24
        base_fee += (exceeding_hours / 24).floor * 5000
        exceeding_hours %= 24
      end

      base_fee + exceeding_hours * exceeding_rate[vehicle_type]
    end
  end

  def validate_attributes
    unless slot_sizes.all? { |e| (0..2).include?(e)}
      errors << 'Invalid size. Must be between 0 and 2, equivalent to S, M, and L parking slot size.'
    end
  end

  def identify_slot_sizes(slot_sizes)
    hash_slot_sizes = Hash.new { |hash, key| hash[key] = [] }
    slot_sizes.each_with_index do |value, index|
      size = case value
             when 0 then 'S'
             when 1 then 'M'
             else 'L'
             end

      hash_slot_sizes[size] << index
    end

    hash_slot_sizes
  end
end