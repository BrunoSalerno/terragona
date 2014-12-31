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
            {:name=>'Provincia Buenos Aires',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Santa Fe',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Córdoba',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'La Pampa',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Entre Ríos',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Corrientes',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Mendoza',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'San Luis',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'San Juan', :fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'La Rioja', :fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Neuquén', :fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Río Negro',:fcode=>'ADM1',:children_fcode=>'ADM2'},
            {:name=>'Uruguay',:fcode=>'PCLI',:country=>'UY',:children_fcode=>'ADM1'}]

terragona = Terragona.new(opts)
terragona.create_family_polygons(provincias, 'provincias', 'municipios')

require 'pry'; binding.pry