-- Project: GGTweak
--
-- Date: September 8, 2012
--
-- Version: 0.1
--
-- File name: GGTweak.lua
--
-- Author: Graham Ranson of Glitch Games - www.glitchgames.co.uk
--
-- Update History:
--
-- 0.1 - Initial release
--
-- Comments: 
-- 
--		GGTweak allows you to store data in JSON format on a remote web server to be used 
--		in your Corona SDK apps. This allows you to tweak the values whenever you want. 
--		Very useful during development. Could be used to store values for balancing in 
--		live games as well.
--
-- Copyright (C) 2012 Graham Ranson, Glitch Games Ltd.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of this 
-- software and associated documentation files (the "Software"), to deal in the Software 
-- without restriction, including without limitation the rights to use, copy, modify, merge, 
-- publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons 
-- to whom the Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in all copies or 
-- substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.
--
----------------------------------------------------------------------------------------------------

local GGTweak = {}
local GGTweak_mt = { __index = GGTweak }

local json = require( "json" )

--- Initiates a new GGTweak object.
-- @param url The URL to load the data from.
-- @param onRefresh Function to be called each time the data is refreshed. Optional.
-- @param refreshTime The duration for the refresh timer. Optional, if not set then you will need to refresh manually ( apart from on creation ).
-- @return The new object.
function GGTweak:new( url, onRefresh, refreshTime )
    
    local self = {}
    
    setmetatable( self, GGTweak_mt )
    	
    self.data = {}
    self.url = url
    self.onRefresh = onRefresh
    self.refreshTime = refreshTime
    
    if self.url then
  	  self:refresh()
    end
    
    return self
    
end

--- Loads data for this GGTweak object from disk.
-- @param path The path to the file.
-- @param baseDirectory The base directory for the file. Optional, defaults to system.ResourceDirectory.
function GGTweak:loadLocalData( path, baseDirectory )
	
	self.path = path
	self.baseDirectory = baseDirectory
	
	local path = system.pathForFile( path, baseDirectory or system.ResourceDirectory )
	local file = io.open( path, "r" )
	
	if not file then
		return
	end
	
	self.data = json.decode( file:read( "*a" ) ) or {}
	io.close( file )
	
	if self.onRefresh and type( self.onRefresh ) == "function" then
		self.onRefresh()
	end
	
end

--- Starts the refresh timer on this GGTweak object.
-- @param time The duration for the refresh timer. Optional, defaults to .refreshTime.
function GGTweak:startRefreshTimer( time )
	
	self.refreshTime = time or self.refreshTime
	
	if self.refreshTime then
		self:stopRefreshTimer()
    	self.timer = timer.performWithDelay( self.refreshTime, function() self:refresh() end, 1 )
    end
    
end

--- Stops the refresh timer on this GGTweak object.
function GGTweak:stopRefreshTimer()
	
	if self.timer then
		transition.cancel( self.timer )
	end
	self.timer = nil
	
end

--- Gets a value from this GGTweak object.
-- @param name The name of the value.
-- @return The value found. Nil if it doesn't exist.
function GGTweak:get( name )
	return self.data[ name ]
end

--- Refreshes the GGTweak object. Called automatically if the object was created with a refresh time.
function GGTweak:refresh()

	if self.url then
		
		local networkListener = function( event )
			if event.isError then
				print( "Network error!")
			else
			
				self.data = json.decode( event.response )
				
				if self.data then
					
					if self.onRefresh and type( self.onRefresh ) == "function" then
						self.onRefresh()
					end
				
				else
					self.data = {}	
				end
				
				self:startRefreshTimer()
				
			end
		end
		
		network.request( self.url, "GET", networkListener )
	
	elseif self.path then
		self:loadLocalData( self.path, self.baseDirectory )
	end
			
end

--- Destroys this GGTweak object.
function GGTweak:destroy()
	self:stopRefreshTimer()
	self.onRefresh = onRefresh
	self.data = nil
	self.url = nil
    self.refreshTime = nil
end

return GGTweak
