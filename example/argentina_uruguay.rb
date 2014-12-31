#
# Example: retrieve Argentina and Uruguay geometries
#
require_relative('../terragona')

opts={
    :default_country=>'AR',
    :geonames_username=>'brunosalerno',
    :allow_holes=>false,
    :target_percent=>0.75,
    :db_username=>'bruno',
    :db_password=>'bruno',
    :db_name=>'geotags'
}

paises=[{:name=>'Argentina',:fcode=>'PCLI'},
        {:name=>'Uruguay',:fcode=>'PCLI',:country=>'UY'}]

terragona = Terragona.new(opts)
terragona.create_family_polygons(paises, 'pcli', 'adm1')