require_relative './generic'
require_relative './geonames'
require_relative './concave_hull'
require_relative './version'

module Terragona
  class Base
    def initialize(options={})
      @options=options
      @minimal_polygon_points = options[:minimal_polygon_points] || 5
    end

    def create_polygons(names,options={})
      opts=@options.merge(options)

      concave_hull = ConcaveHull.new(opts)

      if (!names or names.empty?) and @input.class == Generic::CSVParser
        n = {:name => 'CSV'}
        name = @input.search(n)
        process_points(n,name,concave_hull,opts)
        return [name]
      end

      names.map{|n|
        name = @input.search(n)
        next unless process_points(n,name,concave_hull,opts)
        name
      }.compact
    end

    def create_polygons_family(names,parents_table,children_table,opts={})
      created_names = create_polygons(names,opts.merge({:table => parents_table}))
      children = []
      created_names.each {|c|
        children.concat(c[:children_places])
      }
      create_polygons(children,opts.merge({:table => children_table}))
    end

    private
    def process_points(n, name, concave_hull, opts)
      if name[:points].count < @minimal_polygon_points
        puts "No points for #{n[:name]}"
        return
      end

      unless opts[:dont_create_polygons]
        if concave_hull.perform(name[:points],name[:place_name],name[:place_id])
          puts "Polygon created for #{n[:name]}"
        end
      end

      # Thought the polygon might have not been created, we return true
      # (so we retrieve it's children). The only case where we don't want the children is if
      # there are no enough points.

      true

    end
  end

  class Geonames
    class API < Base
      def initialize (options={})
        super
        @input = GeoNames::API.new(options)
      end
    end

    class Dump < Base
      def initialize (options={})
        super
        @input = GeoNames::Dump.new(options)
      end
    end
  end

  class CSVParser < Base
    def initialize (options={})
      super
      @input = Generic::CSVParser.new(options)
    end
  end
end
