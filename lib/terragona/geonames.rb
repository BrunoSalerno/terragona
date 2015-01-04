require 'httpi'
require 'diskcached'
require 'similar_text'
require 'json'
require 'csv'

module Terragona
  module GeoNames
    class Base
      def initialize(args = {})
        @default_country = args[:default_country]
      end

      def search(options)
        country = options[:country] || @default_country
        id = options[:id]
        name = options[:name]
        fcode = options[:fcode]

        children_fcode = options[:children_fcode] || case fcode
                             when 'PCLI' then 'ADM1'
                             when 'ADM1' then 'ADM2'
                             when 'ADM2' then 'ADM3'
                             when 'ADM3' then 'ADM4'
                             when 'ADM4' then 'ADM5'
                             when 'PPLC' then 'PPLX'
                           end

        field_to_compare = options[:field_to_compare] || calculate_field_to_compare(fcode)
        children_field_to_compare = calculate_field_to_compare(children_fcode)
        field_to_compare_value = options[:field_to_compare_value]

        if field_to_compare_value.nil?
          fetch_geonames(name,country,nil,nil).each{|g|
            if g[:fcode] == fcode
              name = g[:name]
              id = g[:geonameId]
              field_to_compare_value = g[field_to_compare]
              break
            end
          }
        end

        points = []
        children_places = []
                        
        fetch_geonames(nil,country,field_to_compare,field_to_compare_value).each{|g|
            points.push({:x=>g[:lng],:y=>g[:lat]})
            if g[:fcode] == children_fcode and children_field_to_compare
              child={:name=>g[:name],
                     :id=>g[:geonameId],
                     :fcode=>g[:fcode],
                     :country=>g[:countryCode],
                     :field_to_compare_value=>g[children_field_to_compare]}
              children_places.push(child)
            end
        }

        {:children_places=>children_places,:points=>points,:place_name=>name,:place_id=>id}
      end

      private

      def calculate_field_to_compare(fcode)
        case fcode
          when 'PCLI' then :countryCode
          when 'ADM1' then :adminCode1
          when 'ADM2' then :adminCode2
          when 'ADM3' then :adminCode3
          else nil
        end
      end
    end

    class API < Base
      URL = 'http://api.geonames.org/searchJSON'
      def initialize(args = {})
        super
        @username = args[:geonames_username]
        cache_expiration_time = args[:cache_expiration_time] || 7200
        @cache=Diskcached.new('/tmp/cache',cache_expiration_time,true)
      end

      def fetch_geonames(name,country,admin_code_type,admin_code)
        admin_code_str = admin_code ? "&#{admin_code_type}=#{admin_code}" : ''
        name_str = name ? "q=#{name}&" : ''

        @cache.cache("geonames_name=#{name}&country=#{country}#{admin_code_str}&full666") do
          url = URI.escape(%Q{#{URL}?#{name_str}country=#{country}#{admin_code_str}&style=FULL&order_by=relevance&maxRows=1000&username=#{@username}})
          request = HTTPI::Request.new(url)
          data = HTTPI.get(request)
          JSON.parse(data.body,:symbolize_names=>true)[:geonames]
        end
        
      end
    end

    class Dump < Base
      HEADERS = [:geonameId, 
                 :name, 
                 :asciiname, 
                 :alternatenames, 
                 :lat,
                 :lng,
                 :fclass,
                 :fcode,
                 :countryCode,
                 :cc2,
                 :adminCode1,
                 :adminCode2,
                 :adminCode3,
                 :adminCode4,
                 :population,
                 :elevation,
                 :dem,
                 :timezone,
                 :modificaion_date]
                 
      def initialize(args = {})
        super
        
        if not args[:dump]
          puts 'No dump file provided'
          return
        end
        @file = File.open(args[:dump])
        @admin_codes_cache = {:adminCode1=>{},
                              :adminCode2=>{},
                              :adminCode3=>{},
                              :adminCode4=>{}}
                              
        @max_points = args[:max_points]                    
      end
      
      def fetch_geonames(name, country, admin_code_type, admin_code)
        if admin_code_type and 
           @admin_codes_cache[admin_code_type] and 
           @admin_codes_cache[admin_code_type][admin_code]
        
          @admin_codes_cache[admin_code_type][admin_code]
           
        else
          dump_parser(name, country, admin_code_type, admin_code)
        end
      end
      
      private
      def dump_parser(name, country, admin_code_type, admin_code)
        @file.rewind
        records = @max_points ? @file.first(@max_points) : @file
        records.map {|l| 
          begin
            raw=CSV.parse_line(l,{:col_sep => "\t"})            
          rescue
            next
          end

          hash = {}
          HEADERS.each_with_index {|h,index| hash[h] = raw[index]}
          
          cache_hash(hash)
          
          next unless (name and name.similar(hash[:name]) > 30) or
                      (name and hash[:alternatenames] and hash[:alternatenames].include? name) or                       
                      (admin_code_type and admin_code and hash[admin_code_type] == admin_code)
          
          next if (country and country != hash[:countryCode]) 
          
          hash  
        }.compact
      end
      
      def cache_hash(hash)
        [:adminCode1,:adminCode2,:adminCode3,:adminCode4].each {|adm|
          if hash[adm] and not @admin_codes_cache[adm][hash[adm]]
            @admin_codes_cache[adm][hash[adm]]=[]
          end
          if hash[adm] and not @admin_codes_cache[adm][hash[adm]].include? hash
            @admin_codes_cache[adm][hash[adm]].push(hash)
          end
        }
      end
    end

  end
end
