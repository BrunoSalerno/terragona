require 'httpi'
require 'diskcached'
require 'similar_text'
require 'json'

class GeoNames
  URL='http://api.geonames.org/searchJSON'

  def initialize(args = {})
    @default_country = args[:default_country]
    @username = args[:username]
    cache_expiration_time = args[:cache_expiration_time] || 7200
    @cache=Diskcached.new('/tmp/cache',cache_expiration_time,true)
  end

  def search_in_place(place,name,fcode,children_fcode,admin_boundary,country,field_to_compare)
    country ||= @default_country

    geonames = @cache.cache("geonames_name=#{name}&country=#{country}") do
      url = URI.escape("#{URL}?q=#{name}&country=#{country}&order_by=relevance&maxRows=1000&username=#{@username}")
      request = HTTPI::Request.new(url)
      data = HTTPI.get(request)
      JSON.parse(data.body,:symbolize_names=>true)[:geonames]
    end

    points = []
    children_places = []
    place ||= {}

    if place.empty?
      geonames.each{|g|
        if g[:fcode]==fcode
          next if admin_boundary and not g[:adminName1].similar(admin_boundary)>40
          place[:name]=g[:name]
          place[:id]=g[:geonameId]
          break
        end
      }
    end

    # Lookup for children and points

    children_fcode ||= case fcode
                         when 'PCLI' then 'ADM1'
                         when 'ADM1' then 'ADM2'
                         when 'ADM2' then 'ADM3'
                         when 'ADM3' then 'ADM4'
                         when 'ADM4' then 'ADM5'
                         when 'PPLC' then 'PPLX'
                       end

    field_to_compare ||= case fcode
                           when 'PCLI' then :countryName
                           when 'ADM1' then :adminName1
                           when 'ADM2' then :adminName2
                         end


    geonames.each{|g|
      if field_to_compare and g[field_to_compare] and g[field_to_compare].similar(place[:name])>40
        points.push({:lon=>g[:lng],:lat=>g[:lat]})
        if g[:fcode] == children_fcode
          children_places.push({:name=>g[:name],:id=>g[:geonameId],:fcode=>g[:fcode],:country=>g[:countryCode]})
        end
      end
    }

    {:children_places=>children_places,:place=>place,:points=>points}
  end
end