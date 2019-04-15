require 'csv'
require 'svy21'
require 'date'
require 'json'
require 'rest-client'
require 'ostruct'

namespace 'development' do
  desc "Load Carpark Information into Database"
  task :carparkInfo => :environment do
    CarparkInformation.delete_all
    puts "######## Loading Development Carpark Information from API - Start ########"
    CSV.foreach("app/assets/config/hdb-carpark-information.csv", :headers => true) do |row|
      # Longtitude => X Coordinate, Latitude => Y Coordinate
      lat_lon = SVY21.svy21_to_lat_lon(row['y_coord'].to_f, row['x_coord'].to_f)
      CarparkInformation.create(
        :car_park_no => row['car_park_no'],
        :address => row['address'],
        :x_coord => lat_lon[1],
        :y_coord => lat_lon[0]
      )
    end
    puts "######## Loading Development Carpark Information from API - End ########"
  end

  desc "Load Carpark Parking Lots Information into Database"
  task :parkingLotInfo => :environment do
    CarparkParkingInformation.delete_all
    current_DateTime = DateTime.now
    puts "######## Loading Development Carpark Parking Lots Information from API - Start ########"
    response = RestClient.get 'https://api.data.gov.sg/v1/transport/carpark-availability', {date_time: current_DateTime, accept: :json}
    processResp = JSON.parse(response.body, object_class: OpenStruct)
    carparkDataList = processResp.items[0].carpark_data
    carparkDataList.each do |carpark|
      availableLots = 0
      totalLots = 0
      carpark.carpark_info.each do |parkingLotsData|
        availableLots += parkingLotsData.lots_available.to_i
        totalLots += parkingLotsData.total_lots.to_i
      end
      #Omit entries of carpark that has 0 available parking lots to DB
      if availableLots != 0
        CarparkParkingInformation.create(
            :carpark_number => carpark.carpark_number,
            :total_lots => totalLots,
            :lots_available => availableLots
        )
      end
    end
    puts "######## Loading Development Carpark Parking Lots Information from API - End ########"
  end
end

namespace 'test' do
  desc "Load Carpark Information into Database"
  task :carparkInfo => :environment do
    CarparkInformation.delete_all
    puts "######## Loading Test Carpark Information from API - Start ########"
    CSV.foreach("app/assets/config/test-hdb-carpark-information.csv", :headers => true) do |row|
      # Longtitude => X Coordinate, Latitude => Y Coordinate
      lat_lon = SVY21.svy21_to_lat_lon(row['y_coord'].to_f, row['x_coord'].to_f)
      CarparkInformation.create(
          :car_park_no => row['car_park_no'],
          :address => row['address'],
          :x_coord => lat_lon[1],
          :y_coord => lat_lon[0]
      )
    end
    puts "######## Loading Test Carpark Information from API - End ########"
  end

  desc "Load Carpark Parking Lots Information into Database"
  task :parkingLotInfo => :environment do
    CarparkParkingInformation.delete_all
    puts "######## Loading Test Carpark Parking Lots Information from API - Start ########"
    CSV.foreach("app/assets/config/test-carpark-parking-information.csv", :headers => true) do |row|
      CarparkParkingInformation.create(
          :carpark_number => row['carpark_number'],
          :total_lots => row['total_lots'],
          :lots_available => row['lots_available']
      )
    end
    puts "######## Loading Test Carpark Parking Lots Information from API - End ########"
  end
end