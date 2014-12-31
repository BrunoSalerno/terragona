#
# Example: retrieve Argentina and Uruguay geometries
#
require_relative('../terragona')

opts={
    :default_country=>'AR',
    :username=>'brunosalerno',
    :allow_holes=>false,
    :target_percent=>0.75,
    :user=>'bruno',
    :password=>'bruno',
    :database=>'geotags'
}

paises=[{:name=>'Argentina',:fcode=>'PCLI'},
        {:name=>'Uruguay',:fcode=>'PCLI',:country=>'UY'}]

terragona = Terragona.new(opts)
terragona.create_family_polygons(paises, 'pcli', 'adm1')

require 'pry'; binding.pry