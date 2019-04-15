class NearestCarparks < ActiveModelSerializers::Model

  attr_accessor :carpark_number, :address, :latitude, :longtitude, :total_lots, :available_lots, :distance_apart

  def initialize carpark_number, address, latitude, longtitude, total_lots, available_lots, distance_apart
    @carpark_number = carpark_number
    @address = address
    @latitude = latitude
    @longtitude = longtitude
    @total_lots = total_lots
    @available_lots = available_lots
    @distance_apart = distance_apart
  end

end