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
		Data storage
			- SetPoints, GivePoints, TakePoints, SaveItem, GiveItem, TakeItem aren't used
			- Only uses SetData and GetData
			- Means you have to update ALL the information stored on a player rather than just what's been changed
PointShop problems:
	Inefficient provider detection
		- Finds every provider and includes them
		- Sets up a table of providers
		- At this point, it already knows what provider it should use (config file)
		- It also assumes it will find a file in lua/providers called provider_name.lua
		- Much simpler to just try and include "(config.provider_name).lua"
	Fallback system
		- Idea is that if a provider fails, you can use another method to store and retrieve data
		- Doesn't work out so well.
		- For this to work properly, ALL providers need to be kept in-sync
		- This doesn't happen
		- Don't use it
	Retrieval of data
		- Gets all data at once (points & items)
		- Should get points and items separately
		- Easier to code
		- More efficient for when you just need one
		- If you need both, you're going to have to run two queries anyway
	Updating data
		- Updates ALL data at once- points and every single item
		- Should update points and items separately, then each item should be separate
		- Means if you want to increase their points by 10, you increase their points by 10
			and then you have to convert all their items and modifications into JSON format
		- Really inefficient
	Changing points
		- Uses what it thinks is latest version of points when setting/adding/subtracting
		- Means if points get changed by external source, changes are overridden
		- Should first retrieve points, or use a query with maths
		- Afterwards, should update cached value or just not cache it
	Cached data
		- Caches all data when a player first connects
		- Any changes made by external sources will be overridden
		- When the player leaves, it re-saves all the cached data to storage
	PS_ModifyItem (sv_player_extension)
		- Assumes modifications will be saved properly
		- Changes item before even attempting to save modifications 
	ValidateItems (sh_pointshop)
		- Removes items not found on server
		- Won't work for multiple servers with different items on each

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
			itemName- item name
			itemEquipped- if the item is equipped. True or False
			itemModifications- any modifications to the item
Data variables:
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

-- Configuration
-- MySQL connnection settings
local mysql_host		= '127.0.0.1'
local mysql_port		= 3306
local mysql_user		= 'username'
local mysql_pass		= 'password'
local mysql_database	= 'database'
-- Table settings
local mysql_pointstable	= 'PlayerPSPoints'
local mysql_itemstable	= 'PlayerPSItems'




-- END OF CONFIGURATION. DO NOT CHANGE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU'RE DOING.
-- Connect to database using configuration
local db = mysqloo.connect(mysql_host, mysql_user, mysql_pass, mysql_database, mysql_port)
-- Create our queue variable. Used to queue up queries when connection fails.
-- Each item is a table with two items- the query string and callback to run on success with returned data
local queue = {}

-- The 64-bit Steam ID which bots start from. Each additional bot adds 1 to the Steam ID.
local bot_starting_steamid = 90071996842377216

-- When we connect to the database
function db:onConnected()
	print("[MySQL] INFO: PointShop- Connected to database!")
	-- Iterate through queued queries in correct order
	for key, value in ipairs(queue) do
		print("[MySQL] DEBUG: Executing queue- " .. value[1])
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


--[[
	Our query function. Two arguments:
		sql_string- string containing the query to run
		success_callback- the function to run when the query successfully runs. 
			Passes returned data to it.
			Optional
	Data returned is a table. 
		Each index is a row (numeric). Starts from 1
		Each value is a sub-table.
			Each index is the column name (e.g. playerID)
			Each value is the column value (e.g. 1234)
--]]
function query(sql_string, success_callback)
	-- Create a query object by running our query
	local q = db:query(sql_string)
	if q == nil then
		table.insert(queue, {sql_string, success_callback})
		print("[MySQL] DEBUG: Queuing query (query object is nil): "..sql_string)
		return
	end
	
	-- Function to run if query runs successfully
	function q:onSuccess(data)
		if success_callback ~= nil then
			success_callback(data)
		end
	end
	
	-- Function to run if query throws error
	function q:onError(err)
		-- If we've disconnected from the database
		if db:status() == mysqloo.DATABASE_NOT_CONNECTED then
			-- Add the query to the queue and try to connect
			table.insert(queue, {sql_string, success_callback})
			print("[MySQL] DEBUG: Queuing query (not connected): "..sql_string)
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
	Checks if a given 64-bit Steam ID is invalid
	If it is nil, we are in singleplayer.
	If it is greater than or equal to bot_starting_steamid, the player is a bot.
--]]
function IsInvalidSteamID64(steam64id)
	if steam64id == nil then return true end
	steam64id = tonumber(steam64id) 
	if steam64id == nil or steam64id >= bot_starting_steamid then return true end
	return false
end


--[[
	Gets the player's points and items, then sends them to the callback
 		ply = the player to get points & items for
		callback = the function to send the points and items to
	After successful retrieval of player data, callback function is sent points and items table
--]]
function PROVIDER:GetData(ply, callback)
	local playerid = ply:SteamID64()
	if IsInvalidSteamID64(playerid) then return end
	
	-- Query the player's points first
	local sql_string = "SELECT playerPoints FROM " .. mysql_pointstable .. " WHERE playerSteam64 = " .. playerid
	query(sql_string, function(data)
		-- If no rows are returned, stop here. PointShop will default to no points and items (a new player).
		if data[1] == nil then return end
		local points = data[1].playerPoints
		
		-- Now get the player's items
		local sql_string = "SELECT itemName, itemEquipped, itemModifications FROM " .. mysql_itemstable .. " WHERE playerSteam64 = " .. playerid
		query(sql_string, function(data)
			local items = {}
			-- Loop through returned rows and extract item data from each row
			for key, row in pairs(data) do
				-- Check if modifications is nil. If not, it's a JSON string.
				local modifications = row.itemModifications
				if modifications != nil then modifications = util.JSONToTable(modifications) end
				-- Add the item to the player's items table, along with modifications and if it's equipped
				items[row.itemName] = {Modifiers = modifications, Equipped = row.itemEquipped}
			end
			
			-- Run the passed function with the player's points and items
			callback(points, items)
		end)
	end)
end


--[[
	Updates all of a player's items and their points. Really inefficient.
		Points- must be a positive number. Floats will be truncated.
		Items- must be a table. Empty tables can be sent (no items).
--]]
function PROVIDER:SetData(ply, points, items)
	local playerid = ply:SteamID64()
	if IsInvalidSteamID64(playerid) then return end
	
	-- Validate points
	points = math.floor(tonumber(points))
	if points == nil or points < 0 then return end
	
	-- Enforce items being a table. If no items, an empty table should be sent (doesn't equate to nil)
	if type(items) != "table" then return end
	
	-- Update points first. We should only update items if the first query was successful.
	-- Otherwise, a player could end up losing an item, but not gaining the points from selling it.
	local sql_string = "UPDATE " .. mysql_pointstable .. " SET playerPoints = " .. points .. " WHERE playerSteam64 = " .. playerid
	query(sql_string, function(data)
		-- First remove all stored items for the player
		local sql_string = "DELETE FROM " .. mysql_itemstable .. " WHERE playerSteam64 = " .. playerid
		query(sql_string, function(data)
			-- Check if the player has any items to insert
			if next(items) == nil then return end
			
			-- Create the base string for the query
			local sql_string = "INSERT INTO " .. mysql_itemstable .. "(playerSteam64, itemName, itemEquipped, itemModifications) VALUES "
			
			-- Iterate through the items in the table and append them to the query
			local previous_items = false
			for item, properties in pairs(items) do
				-- Add a comma at the end of the previous item
				if previous_items then sql_string = sql_string .. ", "
				else previous_items = true end
				
				local equipped = "FALSE"
				if properties.Equipped then equipped = "TRUE" end
				
				local modifications = "NULL"
				if type(properties.Modifiers) == "table" and next(properties.Modifiers) ~= nil then 
					modifications = "'" .. util.TableToJSON(properties.Modifiers) .. "'" 
				end
				
				-- Append the item to the query
				sql_string = sql_string .. "(" .. playerid .. ", '" .. item .. "', " .. equipped .. ", " .. modifications .. ")"
			end
			
			-- Run the insert query to add the items
			query(sql_string, nil)
		end)
	end)
end