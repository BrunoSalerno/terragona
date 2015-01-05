terragona
=========

Create polygons for [GeoNames](http://www.geonames.org) places.
This means: Create concave polygons using geonames places and store them in a postgres/postgis database.
See [ST_Concave_Hull](http://postgis.net/docs/ST_ConcaveHull.html).

![alt tag](https://cloud.githubusercontent.com/assets/6061036/5606205/2216ff3c-9402-11e4-9123-fff91369208e.png)


So, am I saying you can get the geometries of all places magically? Sort of... 
As you can see, the results are not *very* accurate. But they are interesting.

  
Install
-------

`gem install terragona`

or add `gem 'terragona'` to your Gemfile

Usage
-----

First, create a db in postgres and install the postgis extension.

You can use the GeoNames API, with the Terragona::API class, or download
a dump, (Terragona::Dump class) and specify the dump file path in opts. The API is faster 
but less accurate (max 1000 points per request). The dump is more accurate but much slower (please, 
use country dumps, not the world dump: it's to big -~9 million points- and could take lots of time.). For example:
with the API, the Italy polygon is drawn using 1000 points. With the dump, the input is ~95.000 points. 
You can use the `max_points` option to limit this number.

The slow part of the process is when points are filtered: the ones that are isolated are discarded. 
This has to be refactored.

Besides the source of the points, options `target_percent` and `max_distance_ratio` control the shape of
the polygons. See the options. 


With API
```ruby
require 'terragona'

opts = {...}
countries=[{:name=>'Argentina',:fcode=>'PCLI',:country=>'AR'},
           {:name=>'Uruguay',:fcode=>'PCLI',:country=>'UY'}]

terragona = Terragona::API.new(opts)
terragona.create_polygons_family(countries, 'countries', 'countries_subdivisions')

```

With Dump, and using returned children places

```ruby
require 'terragona'

opts={
	:default_country=>'IT',
	:target_percent=> 0.85,
	:max_distance_ratio=>1.6,
	:db_username=>'mydbuser',
	:db_password=>'mydbpsswd',
	:db_name=>'mydb',
	:dump=>'/path/to/dump/IT.txt'}

italy=[{:name=>'Italy',:fcode=>'PCLI'}]

terragona=Terragona::Dump.new(opts)
result=terragona.create_polygons_family(italy,'italy','italian_regions')

italian_rest=[]
result.each {|r|
	italian_rest.concat(r[:children_places])
}
terragona.create_polygons_family(italian_rest,'province','comuni')
```

Methods
-------

```
create_polygons(<array of places>, options)
  
create_polygons_family(<array of places>, <first order geometries table name>, <second order geometries table name>, options)
```

Each place in the array of places is a hash with this keys:

```
:name                
:fcode                   GeoNames Feature Code 
:id                      (optional)               
:children_fcode          (optional)
:country                 (optional)
:field_to_compare        (optional) (:adminCode1, :adminCode2 or :adminCode3)
:field_to_compare_value  (optional)
```

The methods create the tables, fill them with polygons and return the following hash:

```
{:children_places=>array of hashes, :points=>array of points([x,y]), :place_name=>string, :place_id=>string}
```

Options
------

```
dump                    Only for Dump. Path to dump file.
max_points              Only for Dump. Max number of points to consider from
                        dump file.            
default_country         Default country.
geonames_username       Only for API. Geonames API username.
cache_expiration_time   Default: 7200.
projection              Default: EPSG 4326 (WGS84).
target_percent          Require to draw the concave polygons. 
                        Closer to 1: convex. Closer to 0, concave. Default: 0.8. 
allow_holes             Can the polygons have holes? Default: false. 
max_distance_ratio      Points distant more than this ratio times from the average 
                        distance between points are not considered. Default: 1.6.
minimal_polygon_points  Minimal number of points to build a polygon.
dont_create_polygons    (boolean) Default: false.
table                   Table where polygons are saved. This option is overriden 
                        by args of create_polygons_family method.
```

Postgres options
```
db_name                The db *must* have the Postgis extension installed.
db_username
db_password
db_host                Default: localhost.
db_port                Default: 5432.
db_max_connections     Default: 10.
```

TODO
----
- [x] Check of geometry type before saving
- [x] Use dumps as input (not only API)
- [ ] Generate multipolygon in ConcaveHull. Use some clustering algorithm.
- [ ] Improve/replace distant points algorithm. Use some clustering algorithm.
  
Useful data
-----------
* [GeoNames Country Codes](http://www.geonames.org/countries/)
* [GeoNames Feature Codes](http://www.geonames.org/export/codes.html)
* [GeoNames Dumps download page](http://download.geonames.org/export/dump/)

License
-------

MIT.
