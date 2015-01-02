require_relative 'lib/geonames'
require_relative 'lib/concave_hull'

class Terragona
  def initialize(options={})
    @options=options
    @minimal_polygon_points = options[:minimal_polygon_points] || 5
  end

  def create_polygons(names,options={})
    opts=@options.merge(options)
    geonames = GeoNames.new(opts)
    concave_hull = ConcaveHull.new(opts) if not opts[:dont_create_polygons]

    names.map{|n|
      name= geonames.search_in_place(
          n[:name],n[:fcode],n[:children_fcode],n[:country],n[:field_to_compare],n[:field_to_compare_value])

      if name[:points].count < @minimal_polygon_points
        puts "No points for #{n[:name]}"
        next
      end

      unless opts[:dont_create_polygons]
        concave_hull.perform(name[:points],n[:name])
        puts "Polygon created for #{n[:name]}"
      end
      name
    }
  end

  #
  # Create polygons for parent and children
  #
  def create_polygons_family(names,parents_table,children_table,opts={})
    created_names = create_polygons(names,opts.merge({:table => parents_table}))
    children = []
    created_names.each {|c|
      children.concat(c[:children_places])
    }
    create_polygons(children,opts.merge({:table => children_table}))
  end
end
