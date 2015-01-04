#
# Example: retrieve Brazil geometries
#
require_relative('../terragona')

opts={
    :default_country=>'BR',
    :geonames_username=>'brunosalerno',
    :allow_holes=>false,
    :target_percent=>0.75,
    :db_username=>'bruno',
    :db_password=>'bruno',
    :db_name=>'geotags'
}

brazil=[{:name=>'Brazil',:fcode=>'PCLI'}]

terragona = Terragona::API.new(opts)
terragona.create_polygons_family(brazil, 'brazil', 'brazil_states')
