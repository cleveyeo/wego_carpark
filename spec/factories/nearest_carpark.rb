FactoryBot.define  do
  factory :nearestCP do
    carpark_number { "A34" }
    address { "Eunos" }
    latitude { "1.32433" }
    longtitude { "1.87654" }
    total_lots { "80" }
    available_lots { "20" }
    distance_apart { "34.5432" }
  end
end
