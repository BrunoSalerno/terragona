terragona
=========

Create polygons for [geonames](www.geonames.org) places.
This means: Create concave polygons using geonames places and store them in a postgres/postgis database.

So, am I saying you can get the geometries of all places magically? Sort of... 
The results are not *very* accurate. But they are interesting.
  
Install
-------

git clone this repository

Usage
-----

```
opts = {...}
sp = [{:name=>'São Paulo',:fcode=>'ADM1'}]

terragona = Terragona.new(opts)
terragona.create_polygons_family(sp, 'sao_paulo_state', 'sao_paulo_municipalities')

```

See the example folder.

Methods
-------

```
create_polygons(<array of places>, <first order geometries table name>)
  
create_polygons_family(<array of places>, <first order geometries table name>, <second order geometries table name>)
```

Each place in the array of places is a hash with this keys:

```
:place               (optional) A hash containing :name, :id and :adminCode1 or :adminCode2 or :adminCode3
:name                Obligatory if no place is passed
:fcode               
:children_fcode      (optional)
:country             (optional)
:field_to_compare    (optional)
```

The methods create the tables, fill them with the polygons and return the following hash:

```
{:children_places=>array of hashes, :place=>hash, :points=>array of points([x,y])}
```

Options
------
```
default_country         Default country for geonames queries.
geonames_username       Geonames API username.
cache_expiration_time   Default: 7200.
projection              Default: EPSG 4326 (WGS84).
target_percent          Require to draw the concave polygons. Default: 0.8. 
                        See [ST_Concave_Hull](http://postgis.net/docs/ST_ConcaveHull.html)
allow_holes             Can the polygons have holes? Default: yes. 
                        See [ST_Concave_Hull](http://postgis.net/docs/ST_ConcaveHull.html)
max_distance_ratio      Points distant more than this ratio times than the average distance between points 
                        are not considered for drawing the polygons. Default: 1.6.
minimal_polygon_points  Minimal number of points to build a polygon.
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

License
-------

MIT.