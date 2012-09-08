GGTweak
============

GGTweak allows you to store data in JSON format on a remote web server to be used in your 
Corona SDK apps. This allows you to tweak the values whenever you want. Very useful during 
development. Could be used to store values for balancing in live games as well.

Basic Usage
-------------------------

##### Require the code
```lua
local GGTweak = require( "GGTweak" )
```

##### Create your tweak library, passing in a url, callback function and refresh time.
```lua
local tweak = GGTweak:new( "http://localhost/data.json", onRefresh, 1000 )
```

##### Get a value
```lua
print( tweak:get( "testValue" ) )
```

##### Print a value in the refresh function.
```lua
local onRefresh = function()
	print( tweak:get( "testValue" ) )
end
```

##### Force a refresh
```lua
tweak:refresh()
```

##### Stop the refresh timer
```lua
tweak:stopRefreshTimer()
```

##### Restart the refresh timer
```lua
tweak:startRefreshTimer()
```

##### Create a library and load data locally. Useful when you already have confirmed your values for live apps.
```lua
local tweak = GGTweak:new( nil, onRefresh )
tweak:loadLocalData( "localData.json" )
```

##### Destroy the library
```lua
tweak:destroy()
tweak = nil
```

Update History
-------------------------

##### 0.1
Initial release