require 'geokit'
require 'sequel'

class ConcaveHull
  def initialize(options = {})
    @projection = options[:projection] || 4326
    @table  = options[:table] || 'concave_hull'
    @target_percent = options[:target_percent] || 0.8
    @allow_holes = options[:allow_holes]
    @allow_holes = false if @allow_holes.nil?
    @max_distance_ratio = options[:max_distance_ratio] || 1.6

    db_options={
        :database=> options[:db_name],
        :user=> options[:db_username],
        :password=> options[:db_password],
        :host=> options[:db_host] || 'localhost',
        :port=> options[:db_port] || 5432,
        :max_connections=> options[:db_max_connections] || 10
    }

    @db = Sequel.postgres(db_options)

    create_table
  end

  def perform(points,tags,id)
    filtered_points=filter_points_by_distance(points)
    points_stringified=stringify_points(filtered_points)

    query = %Q{
    ST_ConcaveHull(
      ST_GeomFromText(
        'MULTIPOINT(
          #{points_stringified}
        )',
        #{@projection}
      ),
      #{@target_percent},
      #{@allow_holes})
    }

    create_concave_hull(query,tags,filtered_points.count,id)
  end

  private
  def create_table
    @db << "DROP TABLE IF EXISTS #{@table};"
    @db << "CREATE TABLE #{@table} (id BIGINT PRIMARY KEY, name TEXT, count INT);"
    @db << "SELECT AddGeometryColumn('#{@table}', 'geometry',#{@projection}, 'POLYGON', 2);"
  end

  def create_concave_hull(query, tags, count, id)
    return unless @db["SELECT ST_GeometryType(#{query})"].first[:st_geometrytype] == 'ST_Polygon'
    @db << "INSERT INTO #{@table} (id, name, count, geometry) VALUES (#{id},'#{clean_str tags}',#{count},#{query})"
  end

  def filter_points_by_distance(points)
    distances= points.map {|p0|
      sum = points.map {|pf|
        Geokit::LatLng.new(p0[:lat],p0[:lon]).distance_to(Geokit::LatLng.new(pf[:lat],pf[:lon]))
      }
      {:lat=>p0[:lat],:lon=>p0[:lon],:average=>average(sum)}
    }
    average_distance=average(distances.map{|d| d[:average]})
    distances.map {|d|
      d if d[:average] <= average_distance * @max_distance_ratio
    }.compact
  end

  def stringify_points(points)
    points.map{|p|
      "#{p[:lon]} #{p[:lat]}"
    }.join(',')
  end

  def average(arr)
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end

  def clean_str(str)
    str.gsub("'",' ')
  end
end
