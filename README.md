dilicom_api
===========

API to connect to the Dilicom Hub

Dilicom: http://www.dilicom.net/  
Dilicom Hub API: https://hub-dilicom.centprod.com/documentation/

How to use
----------

```ruby
# use staging server
dilicom = DilicomApi::Hub::Client.new(my_gln, my_password, :test)
# date should be > 8.days.ago
links = dilicom.latest_notices(since: DateTime.now)
# dilicom usually send only one link, but the API could return multiple ones
links.each do |link|
  puts link
end


# use production server
dilicom = DilicomApi::Hub::Client.new(my_gln, my_password, :production)
# all notices since last connection
# :last_connection parameter is optionnal (implicit)
links = dilicom.latest_notices(:last_connection)
links.each do |link|
  puts link
end
```

Implemented
-----------

* get_notices(:last_connection) aliased latest_notices() and latest_notices(:last_connection)
* get_notices(since: datetime) aliased latest_notices(since: datetime)
* get_notices(:initialization) aliased all_notices() ; not supported by Dilicom


License
-------

Under LGPL 3 license, please see LICENSE file
