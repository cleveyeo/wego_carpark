require 'json'
require_relative '../models/nearestCarparks'
require 'rubygems'
require 'geokit'
require 'will_paginate/array'

class CarparksController < ApplicationController
    def nearest
        if !params.has_key?(:latitude) || !params.has_key?(:longtitude) ||
            (params.has_key?(:page) && !params.has_key?(:per_page)) || (!params.has_key?(:page) && params.has_key?(:per_page))
          head :bad_request
        else
          latitude = params[:latitude]
          longtitude = params[:longtitude]
          selectedLocation = Geokit::LatLng.new(latitude, longtitude)

          carparkDetailsList = []
          CarparkParkingInformation.all.each do |parkingLot|
            carparkLot = NearestCarparks.new(parkingLot.carpark_number, "", "", "", parkingLot.total_lots, parkingLot.lots_available, "")
            carparkDetailsList.push(carparkLot)
          end

          carparkDetailsList.each do |carpark|
            carparkData = CarparkInformation.find_by_car_park_no(carpark.carpark_number)
            if !carparkData.nil?
              otherLocation = Geokit::LatLng.new(carparkData.y_coord, carparkData.x_coord)
              distanceDiff = Geokit::GeoLoc.distance_between(selectedLocation, otherLocation)
              carpark.address = carparkData.address
              carpark.latitude = carparkData.y_coord
              carpark.longtitude = carparkData.x_coord
              carpark.distance_apart = distanceDiff.to_f
            end
          end

          #Remove carpark that has no data in HDB Carpark API
          carparkDetailsList.delete_if {|carparkItem| carparkItem.address.blank?}

          if params.has_key?(:page) && params.has_key?(:per_page)
            page_No = params[:page]
            paginate_No = params[:per_page]
            #Check if Page Number or Per Page input are number value (0-9)
            page_No_Check = Integer(page_No) rescue false
            paginate_No_Check = Integer(paginate_No) rescue false
            if !page_No_Check || !paginate_No_Check || page_No_Check <= 0 || paginate_No_Check <= 0
              head :bad_request
            else
              render :json => carparkDetailsList.sort_by{ |carparkObj| carparkObj.distance_apart }.paginate(:page => page_No, :per_page => paginate_No)
            end
          else
            render :json => carparkDetailsList.sort_by{ |carparkObj| carparkObj.distance_apart }
          end

        end
    end
end
