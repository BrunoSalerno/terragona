require 'sequel'

options = {
    :database=>'geotags',
    :user=>'bruno',
    :password=>'bruno',
    :host=>'localhost',
    :port=>5432,
    :max_connections=>10
}

DB = Sequel.postgres(options)