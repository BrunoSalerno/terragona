#
# Example: retrieve Argentina geometries
#
require_relative('../terragona')

opts={
    :default_country=>'AR',
    :geonames_username=>'brunosalerno',
    :allow_holes=>false,
    :max_distance_ratio=>1.6,
    :target_percent=>0.85,
    :db_username=>'bruno',
    :db_password=>'bruno',
    :db_name=>'geotags',
    :dump=>'/home/bruno/Documentos/terragona/AR/AR.txt'
}

argentina=[{:name=>'Argentina',:fcode=>'PCLI'}]

terragona = Terragona::Dump.new(opts)
terragona.create_polygons_family(argentina, 'argentina', 'provincias_argentinas')
