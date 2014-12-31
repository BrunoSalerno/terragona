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
terragona.create_family_polygons(provincias, 'provincias', 'municipios')