require_relative 'lib/geonames'
require_relative 'lib/concave_hull'

class Terragona
  def initialize(options={})
    @options=options
  end

  def create_polygons(names,options={})
    opts=@options.merge(options)
    geonames = GeoNames.new(opts)
    concave_hull = ConcaveHull.new(opts)

    names.map{|n|
      name= geonames.search_in_place(
          n[:place],n[:name],n[:fcode], n[:children_fcode],n[:admin_boundary],n[:country],n[:field_to_compare])

      if name[:points].count < 3
        puts "No points for #{n[:name]}"
        next
      end

      concave_hull.perform(name[:points],n[:name])
      puts "Polygon created for #{n[:name]}"
      name
    }
  end

  #
  # Create polygons for parent and children
  #
  def create_family_polygons(names,parents_table,children_table)
    created_names = create_polygons(names,:table => parents_table)
    children = []
    created_names.each {|c|
      children.concat(c[:children_places])
    }
    create_polygons(children,:table => children_table)
  end
end
