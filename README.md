# Content Covered
## 1) Setup Instructions - Development ENV (Using docker-compose)
```
cd <directory where project resides>
docker-compose build
```
This command will download all necessary gems listed in the Gemfile for the application.
```
docker-compose up
```
This command will start up the docker container along with the database and servers needed.
```
docker-compose run web rake db:create db:migrate
```
This command will create the database for both development & test environment.
Tables will also be created only for development database.
```
docker-compose run -e "RAILS_ENV=development" web rake development:carparkInfo development:parkingLotInfo
```
This command will load data into our 2 respective tables by calling the respective APIs.
```
docker-compose run web
```
**Run this command on a different terminal window but inside of the project directory.**

This command will start up the Rails Server and you will be able to access the default rails. 
```
docker-compose down
```
Run this command after you had stop both servers.
This will bring down all the containers.
## Table --> API Call (Development)
* carpark_informations --> app/assets/config/hdb-carpark-information.csv
    * hdb-carpark-information.csv is downloaded from https://data.gov.sg/dataset/hdb-carpark-information
* carpark_parking_informations
    * Data is loaded into this table by calling https://data.gov.sg/dataset/carpark-availability
## 2) Setup Instructions - Test ENV (Using docker-compose)
```
docker-compose up
```
**This command is needed if you had not start the docker container**

This command will start up the docker container along with the database and servers needed.

```
docker-compose run -e "RAILS_ENV=test" web rake db:create db:migrate
```
**Only include this part of the command 'db:create' if you had not run similiar command from development steps**

This command will help to create the test database and create the respective tables into the database.
```
docker-compose run -e "RAILS_ENV=test" web rake test:carparkInfo test:parkingLotInfo
```
This command will load data into our 2 respective tables from the test csv files created
in "/apps/assets/config" folder.
```
docker-compose run -e "RAILS_ENV=test" web rake spec
```
Run this command to run all rspec test cases
```
docker-compose run -e "RAILS_ENV=test" web rspec spec/<directory of spec files resides>
```
Run this command to test specific test case 
## 3) Access MySQL Database Container
```
docker exec -ti <docker-container-database-name> bash
```
Run this command to connect to the MySQL database container.

A bash command line will appear. It will look something similiar to below,
```
root@2cae2d672bc8:/#
```
After which, enter below command to connect to MySQL database.
```
root@2cae2d672bc8:/# mysql -u <user-specific> -p
```
User used will be determine by which user has been specify inside docker-compose.yml.

"-p" is to specify user's password.
## 4) Approach taken 
* Downloaded Carpark Information CSV file and developed rake task to load data to database.
    * Convert of latitude & longtitude SVY21 format to more widely used format (Used 'SVY21' API')
        ```
        lat_lon = SVY21.svy21_to_lat_lon(row['y_coord'].to_f, row['x_coord'].to_f)
        ```
* Direct call of Carpark Parking Lot Information API and developed rake task to load data to database.
    * Implemented the logic of omitting out carparks that has '0' available lots from being loaded into database
    * A carpark may have multiple carpark lots data tagged to it, hence, a loop has been used to consolidate 
      the total parking lots and available lots tagged to this carpark.
      ```
      carparkDataList.each do |carpark|
        availableLots = 0
        totalLots = 0
        carpark.carpark_info.each do |parkingLotsData|
          availableLots += parkingLotsData.lots_available.to_i
          totalLots += parkingLotsData.total_lots.to_i
        end
      ```
* Loop through Carpark Parking Lot Information data and create 'NearestCarparks' object to store necessary information
    * Stored all created 'NearestCarparks' objects to an array 
* Loop through 'NearestCarparks' array and perform SELECT query to Carpark Information table
    * During the loop process, distance between location input from URL and carpark from table will be calculated. 
    * Distance is calculated based on latitude & longtitude, using of 'GeoKit' API
        ```
        selectedLocation = Geokit::LatLng.new(latitude, longtitude)
        otherLocation = Geokit::LatLng.new(carparkData.y_coord, carparkData.x_coord)
        distanceDiff = Geokit::GeoLoc.distance_between(selectedLocation, otherLocation)
        ```
    * Remaining information like total lots, available lots, distance difference will also be stored into 
      each individual 'NearestCarparks' object
* Remove carparks that has no address information from 'NearestCarparks' array
  ```
  carparkDetailsList.delete_if {|carparkItem| carparkItem.address.blank?}
  ```
* 'NearestCarparks' array is sorted based on distance data in ascending order
   ```
   carparkDetailsList.sort_by{ |carparkObj| carparkObj.distance_apart }
   ```
* Depending on whether "Page & Per_Page" parameters are present in the call, results are returned differently.
    * With "Page & Per_Page" parameters, pagination function is implemented with use of 'will_paginate' API
        ```
        carparkDetailsList.sort_by{ |carparkObj| carparkObj.distance_apart }.paginate(:page => page_No, :per_page => paginate_No) 
        ```
* Requests without required parameters latitude & longtitude are returned HTTP status code 400
    * Having 'Page' parameter without 'Per_Page' parameter or vice-versa will also return HTTP status code 400
    ```
    if !params.has_key?(:latitude) || !params.has_key?(:longtitude) ||
       (params.has_key?(:page) && !params.has_key?(:per_page)) || (!params.has_key?(:page) && params.has_key?(:per_page))
      head :bad_request 
    ```
* 'NearestCarparks' array is being used to return result. Filtering of displaying fields are done by using 'active_model_serializers'
    ```
    class NearestCarparksSerializer < ActiveModel::Serializer
      attributes  :address, :latitude, :longtitude, :total_lots, :available_lots
    end    
    ```
* Validation of "Page & Per_Page" parameters are in placed as well.
    * Check if input parameters are of numerical value
    * Check if numerical value is lesser or equal to '0'
    * If any of the above condition are met, HTTP status code 400 will be returned
    ```
    page_No_Check = Integer(page_No) rescue false
    paginate_No_Check = Integer(paginate_No) rescue false
    if !page_No_Check || !paginate_No_Check || page_No_Check <= 0 || paginate_No_Check <= 0
      head :bad_request
    ```
## 5) Challenges faced during development
* Working through on the setup & connection for MySQL database at first without 'docker-compose'
* Developing Rspec test cases after finishing the functionality of application
    * Learnt that there was command to help in generating spec test cases for existing model and controller
## 6) Observation & Learning Notes
* Observed that 'carpark_numbers' can exist in 'Carpark Availability' API but not in 'HDB Carpark Information' dataset.
* Should had started working on Rspec before developing all functions
* 'docker-compose' is a beauty that helps to boost up the speed of setting up development environment.
    * Even database configuration and setup is also included inside of 'docker-compose'.