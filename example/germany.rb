require_relative('../terragona')

opts={
    :default_country=>'DE',
    :geonames_username=>'brunosalerno',
    :target_percent=>0.85,
    :max_distance_ratio=>1.8,
    :db_username=>'bruno',
    :db_password=>'bruno',
    :db_name=>'geotags'
}

germany=[{:name=>'Germany',:fcode=>'PCLI'}]

terragona = Terragona::API.new(opts)
result=terragona.create_polygons_family(germany, 'germany', 'germany_states')
terragona.create_polygons(result[1][:children_places],:table=>'bavaria')
