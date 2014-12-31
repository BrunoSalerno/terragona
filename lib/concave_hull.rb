require 'geokit'
require 'sequel'

class ConcaveHull
  def initialize(options={})
    @projection = options[:projection] || 4326
    @table  = options[:table] || 'concave_hull'
    @target_percent = options[:target_percent] || 0.8
    @allow_holes = options[:allow_holes]
    @allow_holes=true if @allow_holes.nil?

    db_options={
        :database=> options[:database],
        :user=> options[:user],
        :password=> options[:password],
        :host=> options[:host] || 'localhost',
        :port=> options[:port] || 5432,
        :max_connections=> options[:max_connections] || 10
    }

    @db = Sequel.postgres(db_options)

    create_table
  end

  def perform(points,tags)
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

    create_concave_hull(query,tags,filtered_points.count)
  end

  private
  def create_table
    @db << "DROP TABLE IF EXISTS #{@table};"
    @db << "CREATE TABLE #{@table} (id SERIAL PRIMARY KEY, tags TEXT, count INT);"
    @db << "SELECT AddGeometryColumn('#{@table}', 'geometry',#{@projection}, 'POLYGON', 2);"
  end

  def create_concave_hull(query, tags, count)
    @db << "INSERT INTO #{@table} (tags, count, geometry) VALUES ('#{tags}',#{count},#{query})"
  end

  def filter_points_by_distance(points,max_distance_ratio=1.5)
    distances= points.map {|p0|
      sum = points.map {|pf|
        Geokit::LatLng.new(p0[:lat],p0[:lon]).distance_to(Geokit::LatLng.new(pf[:lat],pf[:lon]))
      }
      {:lat=>p0[:lat],:lon=>p0[:lon],:average=>average(sum)}
    }
    average_distance=average(distances.map{|d| d[:average]})
    distances.map {|d|
      d if d[:average] <= average_distance * max_distance_ratio
    }.compact
  end

  def stringify_points(points)
    points.map{|p|
      "#{p[:lon]} #{p[:lat]}"
    }.join(',')
  end

  def average (arr)
    arr.inject{ |sum, el| sum + el }.to_f / arr.size
  end
end
