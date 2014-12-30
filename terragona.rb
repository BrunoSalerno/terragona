require_relative 'lib/geonames'
require_relative 'lib/concave_hull'

geonames= GeoNames.new({:default_country=>'AR',:username=>'brunosalerno'})
concave_hull=ConcaveHull.new({:allow_holes=>false,:target_percent=>0.75})

provincias=[{:name=>'Buenos Aires F.D.',:fcode=>'ADM1'},
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
            {:name=>'Río Negro',:fcode=>'ADM1'},
            {:name=>'Uruguay',:fcode=>'PCLI',:country=>'UY'}]

provincias.each {|p|
  result=geonames.search_in_place(nil,p[:name],p[:fcode],'PPLX',nil,p[:country])
  if result[:points].count == 0
    puts "No points for #{p[:name]}"
    next
  end
  concave_hull.perform(result[:points],p[:name])
  puts "Polygon created for #{p[:name]}"
}


