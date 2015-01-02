require 'httpi'
require 'diskcached'
require 'similar_text'
require 'json'

class GeoNames
  URL='http://api.geonames.org/searchJSON'

  def initialize(args = {})
    @default_country = args[:default_country]
    @username = args[:geonames_username]
    cache_expiration_time = args[:cache_expiration_time] || 7200
    @cache=Diskcached.new('/tmp/cache',cache_expiration_time,true)
  end

  def search_in_place(options)
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
        if g[:fcode]==fcode
          name = g[:name]
          id = g[:geonameId]
          field_to_compare_value = g[field_to_compare]
          break
        end
      }
    end

    points = []
    children_places = []

    fetch_geonames(name,country,field_to_compare.to_s,field_to_compare_value).each{|g|
        points.push({:lon=>g[:lng],:lat=>g[:lat]})
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
  def fetch_geonames(name,country,admin_code_type,admin_code)
    admin_code_str = admin_code ? "&#{admin_code_type}=#{admin_code}" : ''

    @cache.cache("geonames_name=#{name}&country=#{country}#{admin_code_str}&full") do
      url = URI.escape("#{URL}?q=#{name}&country=#{country}#{admin_code_str}&style=FULL&order_by=relevance&maxRows=1000&username=#{@username}")
      request = HTTPI::Request.new(url)
      data = HTTPI.get(request)
      JSON.parse(data.body,:symbolize_names=>true)[:geonames]
    end
  end

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