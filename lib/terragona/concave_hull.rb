require 'geokit'
require 'sequel'
require_relative 'stats'

module Terragona
  class ConcaveHull
    def initialize(options = {})
      @projection = options[:projection] || 4326
      @table  = options[:table] || 'concave_hull'
      @target_percent = options[:target_percent] || 0.8
      @allow_holes = options[:allow_holes]
      @allow_holes = false if @allow_holes.nil?
      @max_distance_ratio = options[:max_distance_ratio] || 1.6
      @force_homogeneity = options[:force_homogeneity]

      db_options={
          :database=> options[:db_name],
          :user=> options[:db_username],
          :password=> options[:db_password],
          :host=> options[:db_host] || 'localhost',
          :port=> options[:db_port] || 5432,
          :max_connections=> options[:db_max_connections] || 10
      }

      @db = Sequel.postgres(db_options)
      @all_means = []
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
      @db << "SELECT AddGeometryColumn('#{@table}', 'geometry', #{@projection}, 'POLYGON', 2);"
    end

    def create_concave_hull(query, tags, count, id)
      begin
        return unless @db["SELECT ST_GeometryType(#{query})"].first[:st_geometrytype] == 'ST_Polygon'
        @db << "INSERT INTO #{@table} (id, name, count, geometry) VALUES (#{id},'#{clean_str tags}',#{count},#{query})"
      rescue
        puts "Error with #{tags}, Id: #{id}, #{count} points."
      end
    end

    def filter_points_by_distance(points)
      random_points = points.count > 200 ? (0..200).map {|e|
        points[rand(points.count)]
      }.uniq : points

      distances = points.map {|p0|
        sum = random_points.map {|pf|
          if p0[:y] != pf[:y] and p0[:x] != pf[:x]
            Geokit::LatLng.new(p0[:y],p0[:x]).distance_to(Geokit::LatLng.new(pf[:y],pf[:x]))
          end
        }.compact
        {:y=>p0[:y],:x=>p0[:x],:mean=> sum.mean}
      }

      mean = distances.map{|d| d[:mean]}.compact.mean
      @all_means.push mean
      mean_of_means =  @force_homogeneity ? @all_means.compact.mean : nil

      distances.map {|d|
        next unless d[:mean]
        d if (d[:mean]/[mean,mean_of_means].compact.min) < @max_distance_ratio
      }.compact
    end

    def stringify_points(points)
      points.map{|p|
        "#{p[:x]} #{p[:y]}"
      }.join(',')
    end

    def clean_str(str)
      str.to_s.gsub("'",' ')
    end
  end
end
