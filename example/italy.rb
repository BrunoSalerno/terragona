require_relative('../terragona')

opts={
	:default_country=>'IT',
	:geonames_username=>'brunosalerno',
	:target_percent=> 0.85,
	:max_distance_ratio=>1.6,
	:db_username=>'bruno',
	:db_password=>'bruno',
	:db_name=>'geotags'}

italy=[{:name=>'Italy',:fcode=>'PCLI'}]

terragona=Terragona.new(opts)
result=terragona.create_polygons_family(italy,'italy','italian_regions')

italian_rest=[]
result.each {|r|
	italian_rest.concat(r[:children_places])
}
terragona.create_polygons_family(italian_rest,'province','comuni')

require 'pry';binding.pry
