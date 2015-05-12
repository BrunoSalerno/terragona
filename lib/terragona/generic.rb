require 'csv'

module Terragona
  module Generic
    class CSVParser
      def initialize(args = {})
        filename = args[:csv_filename]

        abort "Missing CSV filename. Aborting." unless filename

        @csv = CSV.table(filename)
        @id_counter = 0
      end
      def search(options = {})
        @id_counter +=1

        name = options[:name]

        points = []

        if name == 'CSV'
          children = []

          @csv.each {|p|
            points.push({:x => p[:x], :y => p[:y]})
            children.push({:name => p[:name]})
          }

          children.uniq!

          children_places = (children.count > 1 )? children : []
        else
          @csv.select{|row| row[:name] == name}.each {|p| points.push({:x => p[:x], :y => p[:y]})}
          children_places = []
        end

        {:children_places=>children_places, :points => points, :place_name=> name, :place_id=>@id_counter}
      end
    end
  end
end