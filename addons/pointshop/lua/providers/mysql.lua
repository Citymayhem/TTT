require("mysqloo")
--[[
MySQL module- http://facepunch.com/showthread.php?t=1357773
	Old thread- http://facepunch.com/showthread.php?t=1220537
Original PointShop MySQL module- https://github.com/adamdburton/pointshop-mysql/blob/master/lua/providers/mysql.lua
	Problems:
		Falls back on pdata (local database) if unable to connect to database.
			- Doesn't handle this properly. 
			- The two quickly become out of sync as only problematic changes are applied to pdata
			- pdata and MySQL aren't kept in-sync
		Uses wait
			- Forces server to wait. Why would you use this???
		Doesn't handle lost connection to database properly
			- Should queue up tasks until connection is restored
			- Tries twice. If both fail, uses pdata incorrectly.
		Doesn't create tables if they don't exist automatically
			- You have to run a separate sql statement when adding this to your server
		Tables aren't normalised
			- Items and item modifications are in JSON format
			- Difficult to give players items through just a query
		Uses uniqueid
			- Can't see a reason for needing to use this instead of a 64-bit Steam ID or normal Steam ID
			- Can convert from SteamID -> UniqueID, but not the other way
MySQL Table Structure:
	PlayerPSPoints
		Stores each player's points.
		Uses a player's 64-bit SteamID to uniquely identify them.
		Stores points as an unsigned integer
		Two fields:
			playerSteam64- player's 64-bit Steam ID
			playerPoints- player's points
	PlayerPSItems
		Stores each player's items, if it's equipped and 
			any modifications in JSON format.
		Uses a player's 64-bit SteamID to uniquely identify them.
		Each row is an item a player has. 
			If a player has multiple items, there are multiple rows.
		Four fields:
			playerSteam64- player's 64-bit Steam ID
			playerItem- item name
			itemEquipped- if the item is equipped. True or False
			itemModifications- any modifications to the item
--]]

-- Configuration
-- MySQL connnection settings
local mysql_host		= '91.121.182.29'
local mysql_port		= 3306
local mysql_user		= 'ttt-webstats'
local mysql_pass		= 'ytqEuD8t958aRBY3'
local mysql_database	= 'ttt-webstats'
-- Table settings
local mysql_pointstable	= 'PlayerPSPoints'
local mysql_itemstable	= 'PlayerPSItems'




-- END OF CONFIGURATION. DO NOT CHANGE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU'RE DOING.
-- Connect to database using configuration
local db = mysqloo.connect(mysql_host, mysql_user, mysql_pass, mysql_port)
-- Create our queue variable. Used to queue up queries when connection fails.
-- Each item is a table with two items- the query string and callback to run on success with returned data
local queue = {}

-- When we connect to the database
function db:onConnected()
	-- Iterate through queued queries in correct order
	for index, value in ipairs(queue) do
		query(value[1], value[2])
	end
	-- Empty queue
	queue = {}
end

-- When connection to the database fails. err is a string containing the error message.
function db:onConnectionFailed(err)
	print("[MySQL] ERROR: PointShop- Failed to connect to database.")
	print("[MySQL] ERROR: " .. err)
end

-- Now that our database response functions have been made, connect to the database.
db:connect()

-- Our query function. Two arguments:
--		sql_string- string containing the query to run
--		success_callback- the function to run when the query successfully runs. Passes returned data to it.
function query(sql_string, success_callback)
	-- Create a query object by running our query
	local q = db:query(sql_string)
	
	-- Function to run if query runs successfully
	function q:onSuccess(data)
		success_callback(data)
	end
	
	-- Function to run if query throws error
	function q:onError(err)
		-- If we've disconnected from the database
		if db:status() == mysqloo.DATABASE_NOT_CONNECTED then
			-- Add the query to the queue and try to connect
			table.insert(queue, {sql_string, success_callback})
			db:connect()
		end
		print("[MySQL] ERROR: PointShop- Query produced error.")
		print("[MySQL] ERROR: PointShop- " .. sql_string)
		print("[MySQL] ERROR: PointShop- " .. err)
	end
	
	q:start()
end



-- Pointshop functions
--[[
	Data:
		Points should be an integer
		Items should be a table where the item names are the index
			and the values are sub-tables. Sub tables:
				Index		Value
				Modifiers = {modifications table}
				Equipped = true/false
			e.g. items[item_id] = { 
					Modifiers = {
						color = {
							r = 255,
							g = 0,
							b = 255,
							a = 255
						}
					}, 
					Equipped = false 
				}
--]]

--[[
	Gets the player's points and items, then sends them to the callback
 		ply = the player to get points & items for
		callback = the function to send the points and items to
	After successful retrieval of player data, should send points and items to callback
--]]
function PROVIDER:GetData(ply, callback)
	-- Get the player's 64-bit Steam ID
	local playerid = ply:SteamID64()
	if playerid == 0 then return;
	
	local sql_string = "SELECT playerPoints FROM " .. mysql_pointstable .. " WHERE playerSteam64 = " .. playerid
	query(sql_string, function(data)
		
	end)
end

function PROVIDER:SetPoints(ply, points)

end

function PROVIDER:GivePoints(ply, points)

end

function PROVIDER:SaveItem(ply, item_id, data)

end

function PROVIDER:GiveItem(ply, item_id, data)

end

function PROVIDER:TakeItem(ply, item_id)

end

function PROVIDER:SetData(ply, points, items)

end

