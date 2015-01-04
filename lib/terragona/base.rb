require 'geonames'
require 'concave_hull'
require 'version'

module Terragona
  class Base
    def initialize(options={})
      @options=options
      @minimal_polygon_points = options[:minimal_polygon_points] || 5
    end

    def create_polygons(names,options={})
      opts=@options.merge(options)

      concave_hull = ConcaveHull.new(opts) if not opts[:dont_create_polygons]

      names.map{|n|
        name = @geonames.search(n)

        if name[:points].count < @minimal_polygon_points
          puts "No points for #{n[:name]}"
          next
        end

        unless opts[:dont_create_polygons]
          if concave_hull.perform(name[:points],name[:place_name],name[:place_id])
            puts "Polygon created for #{n[:name]}"
          end
        end
        name
      }
    end

    def create_polygons_family(names,parents_table,children_table,opts={})
      created_names = create_polygons(names,opts.merge({:table => parents_table}))
      children = []
      created_names.each {|c|
        children.concat(c[:children_places])
      }
      create_polygons(children,opts.merge({:table => children_table}))
    end
  end
  
  class API < Base
    def initialize (options={})
      super
      @geonames = GeoNames::API.new(options) 
    end
  end
  
  class Dump < Base
    def initialize (options={})
      super
      @geonames = GeoNames::Dump.new(options) 
    end
  end
  
end