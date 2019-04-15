class NearestCarparksSerializer < ActiveModel::Serializer
  attributes  :address, :latitude, :longtitude, :total_lots, :available_lots
end
