#
# Example: retrieve Sao Paulo (Brazil) geometries
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

sp=[{:name=>'São Paulo',:fcode=>'ADM1'}]

terragona = Terragona::Base.new(opts)
terragona.create_polygons_family(sp, 'sao_paulo', 'sao_paulo_municipalities')
