require 'rails_helper'

RSpec.describe CarparksController, type: :controller do
  describe "nearest method" do
    it "returns a successful response" do
      puts "Successful Response Test - Start"
      expectedResponse_JSON = [{"address":"BLK 464-468 HOUGANG AVENUE 10","latitude":"1.373258465282608","longtitude":"103.8969655694286","total_lots":431,"available_lots":146},{"address":"BLK 401-413, 460-463 HOUGANG AVENUE 10","latitude":"1.3742919962898281","longtitude":"103.89581727903094","total_lots":693,"available_lots":294}]
      get :nearest, :params => { :latitude => "1.37326", :longtitude => "103.897", :page => "1", :per_page => "2" }
      expect(response).to have_http_status("200")
      expect(response.content_type).to eq("application/json")
      expect(response.body).to eq(JSON.generate(expectedResponse_JSON))
      puts "Successful Response Test - End"
    end
    it "returns a Bad Request as response when missing latitude" do
      puts "Missing Latitude Test (Bad Response) - Start"
      get :nearest, :params => { :latitude => "1.37326" }
      expect(response).to have_http_status("400")
      puts "Missing Latitude Test (Bad Response) - End"
    end
    it "returns a Bad Request as response when missing longtitude" do
      puts "Missing Longtitude Test (Bad Response) - Start"
      get :nearest, :params => { :latitude => "1.37326" }
      expect(response).to have_http_status("400")
      puts "Missing Longtitude Test (Bad Response) - End"
    end
    it "returns a Bad Request as response when page is not a number" do
      puts "Page Param Value is not a Number (Bad Request) - Start"
      get :nearest, :params => { :latitude => "1.37326" , :longtitude => "103.897", :page => "a", :per_page => "2" }
      expect(response).to have_http_status("400")
      puts "Page Param Value is not a Number (Bad Request) - End"
    end
    it "returns a Bad Request as response when per_page is not a number" do
      puts "Per_Page Param Value is not a Number (Bad Request) - Start"
      get :nearest, :params => { :latitude => "1.37326" , :longtitude => "103.897", :page => "2", :per_page => "a" }
      expect(response).to have_http_status("400")
      puts "Per_Page Param Value is not a Number (Bad Request) - End"
    end
    it "returns a Bad Request as response when page exist but per_page does not exist" do
      puts "Page Param Exist but Per_Page Param does not exist (Bad Request) - Start"
      get :nearest, :params => { :latitude => "1.37326" , :longtitude => "103.897", :page => "2" }
      expect(response).to have_http_status("400")
      puts "Page Param Exist but Per_page Param does not exist (Bad Request) - End"
    end
    it "returns a Bad Request as response when per_page exist but page does not exist" do
      puts "Per_Page Param exist but Page Param does not exist (Bad Request) - Start"
      get :nearest, :params => { :latitude => "1.37326" , :longtitude => "103.897", :per_page => "a" }
      expect(response).to have_http_status("400")
      puts "Per_Page Param exist but Page Param does not exist (Bad Request) - End"
    end
  end
end
