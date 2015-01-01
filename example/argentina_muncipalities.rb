#
# Example: retrieve some Argentina provinces and municipalities.
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

provincias=[{:name=>'Buenos Aires F.D.',:fcode=>'ADM1',:children_fcode=>'PPLX'},
            {:name=>'Provincia Buenos Aires',:fcode=>'ADM1'},
            {:name=>'Santa Fe',:fcode=>'ADM1'},
            {:name=>'Córdoba',:fcode=>'ADM1'},
            {:name=>'La Pampa',:fcode=>'ADM1'},
            {:name=>'Entre Ríos',:fcode=>'ADM1'},
            {:name=>'Corrientes',:fcode=>'ADM1'},
            {:name=>'Mendoza',:fcode=>'ADM1'},
            {:name=>'San Luis',:fcode=>'ADM1'},
            {:name=>'San Juan', :fcode=>'ADM1'},
            {:name=>'La Rioja', :fcode=>'ADM1'},
            {:name=>'Neuquén', :fcode=>'ADM1'},
            {:name=>'Río Negro',:fcode=>'ADM1'}]

terragona = Terragona.new(opts)
terragona.create_polygons_family(provincias, 'provincias', 'municipios')