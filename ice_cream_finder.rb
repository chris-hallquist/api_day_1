require 'addressable/uri'
require 'rest-client'
require 'json'
require 'nokogiri'

key = 'AIzaSyCcR6uVFBHen_CeGTGrcjFNFLZz0uaNFJM'

# geocoding: https://maps.googleapis.com/maps/api/geocode/json?parameters
#address
#sensor = false
puts "Please enter your address."
address = gets.chomp
geocode_url = Addressable::URI.new(:scheme => "https",
                                   :host => "maps.googleapis.com",
                                   :path => "/maps/api/geocode/json",
                                   :query_values =>
                                     { :address => address,
                                       :sensor => false }
).to_s

geocode_hash = JSON.parse(RestClient.get(geocode_url))
location = geocode_hash["results"][0]["geometry"]["location"]
start_lat = location["lat"]
start_lng = location["lng"]

place_url = Addressable::URI.new(:scheme => "https",
                     :host => "maps.googleapis.com",
                     :path => "/maps/api/place/nearbysearch/json",
                     :query_values =>
                       {
                         :key => key,
                         :location => "#{start_lat},#{start_lng}",
                         :sensor => false,
                         :radius => 500,
                         :keyword => "ice cream"
                       }
).to_s

place_hash = JSON.parse(RestClient.get(place_url))
place_hash["results"].each_with_index do |place, index|
  puts "#{index}. #{place["name"]}"
end
puts "Enter number of choice."
choice_index = gets.to_i
choice = place_hash["results"][choice_index]
dest_lat = choice["geometry"]["location"]["lat"]
dest_lng = choice["geometry"]["location"]["lng"]

dir_url = Addressable::URI.new(:scheme => "https",
                               :host => "maps.googleapis.com",
                               :path => "/maps/api/directions/json",
                               :query_values =>
                               {
                                 :origin => "#{start_lat},#{start_lng}",
                                 :destination => "#{dest_lat},#{dest_lng}",
                                 :sensor => false
                               }
).to_s

dir_hash = JSON.parse(RestClient.get(dir_url))

dir_hash["routes"][0]["legs"][0]["steps"].each_with_index do |step, i|
  puts "#{i}. #{Nokogiri::HTML(step["html_instructions"]).text}"
end