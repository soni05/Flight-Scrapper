class FlightsController < ApplicationController
  def index
  end
  def search
  	require 'json'
require 'rest_client'
require 'net/http'

  	@origin = params[:from]
  	@dest = params[:to]
  	@dep_date = params[:date]
  	@adult = params[:adults]
  	@child = params[:child]
  	
@origin = @origin[0,3].upcase
@dest = @dest[0,3].upcase

org=@origin
dest=@dest
date=@dep_date

#r_date="2016-01-19"
solution=20
adult=1
child=0
senior=0

urls=[]
trip = "one way"

if trip == "one way" then
 req_param = {
  :request => {
    :slice => [
      {
        :origin => org,
        :destination => dest,
        :date => date
       # :maxStops => 0
      }
    ],
    	:passengers => {
      :adultCount => adult,
      :infantInLapCount => 0,
      :infantInSeatCount => 0,
      :childCount => child,
      :seniorCount => senior
   	 },
   	 :solutions => solution
 #  	 :refundable => false
  	}
   }.to_json
else
req_param =		{
  :request => {
    :slice => [
      {
        :origin => org,
        :destination => dest,
        :date => date,
        :maxStops => 0
      },
      {
        :origin => dest,
        :destination => org,
        :date => r_date,
        :maxStops => 0
      }
    ],
    :passengers => {
      :adultCount => adult,
      :infantInLapCount => 0,
      :infantInSeatCount => 0,
      :childCount => child,
      :seniorCount => senior
    },
     :solutions => solution
 #   :refundable => false
   }
  }.to_json
end



 
#puts req_param

@price = []
@flight_code = Array.new(100) { Array.new(100) }
@flight_number = Array.new(100) { Array.new(100) }
@cabin= Array.new(100) { Array.new(100) }
@arr_time = Array.new(100) { Array.new(100) }
@dep_time = Array.new(100) { Array.new(100) }
@seg_org= Array.new(100) { Array.new(100) }
@seg_dest = Array.new(100) { Array.new(100) }
@flight_name = []
apikey= " AIzaSyB_N9UqlXqX7eKpbK_0R1i3qnZG7awrKgU"
tempkey= "AIzaSyAx7eaVmaIJwZZa8us5QDuzwjsLopJg5K0"



@response = RestClient.post "https://www.googleapis.com/qpxExpress/v1/trips/search?key=#{apikey} ",
              req_param,
             :content_type => :json,
              :accept => :json


result = JSON.parse @response
#puts response.code

@segment_size= []
count=0


@abc = result["trips"]["data"].has_key?("airport")

if @abc == true then

result["trips"]["tripOption"].each do |sol|

     @segment_size[count] = sol["slice"][0]["segment"].size
	
	count+=1
end



k=0

result["trips"]["tripOption"].each do |sol|

	@price[k] = sol["saleTotal"]	

		 m=0
		 sol["slice"][0]["segment"].each do |seg|

	 			@flight_code[k][m] = sol["slice"][0]["segment"][m]["flight"]["carrier"]
	 				
	 				result["trips"]["data"]["carrier"].each do |x|
	 					if @flight_code[k][m] == x["code"]
	 						@flight_name[k]= x["name"]
	 					end
	 				end			

				@flight_number[k][m] = sol["slice"][0]["segment"][m]["flight"]["number"]			
				@cabin[k][m] = sol["slice"][0]["segment"][m]["cabin"]
				@arr_time[k][m] = sol["slice"][0]["segment"][m]["leg"][0]["arrivalTime"]
				@dep_time[k][m] = sol["slice"][0]["segment"][m]["leg"][0]["departureTime"]	
				@seg_org[k][m] = sol["slice"][0]["segment"][m]["leg"][0]["origin"]
				@seg_dest[k][m] = sol["slice"][0]["segment"][m]["leg"][0]["destination"]
				m+=1		
	 	 end

	k+=1
end

@avail_sol=k

citykey= "5acbf729-1e1a-469c-8f40-6899d7db5e80"


response = RestClient.get "http://iatacodes.org/api/v4/cities?api_key=#{citykey}&code=#{@origin}"

result = JSON.parse response
@origin_city = ""
result["response"].each do |i|
	if i["code"] == @origin
		@origin_city = i["name"]
	end
end

response = RestClient.get "http://iatacodes.org/api/v4/cities?api_key=#{citykey}&code=#{@dest}"

result = JSON.parse response
@dest_city = ""
result["response"].each do |i|
	if i["code"] == @dest
		@dest_city = i["name"]
	end
end

  end
end


end