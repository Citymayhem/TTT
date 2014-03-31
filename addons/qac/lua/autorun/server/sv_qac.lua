--[[ 

Hi, This is Zero The Fallen
This is QAC (aka Quack Anti Cheat)
The Config is below, edit it to your likings, as I'll attempt to describe anything that seems confusing.
If you dont understand something, please post on the CH thread!
Thanks


Edit: 12/10
Changelog
---------
Removed File-stealer, Not allowed. Sorry!

12/10

Attempted to fix errors ... I didnt even change shit in the rapid updates... I don't know why it doesnt work.
The fuck?

Hopefully this fixes it.
--]]

util.AddNetworkString("Debug1")
util.AddNetworkString("Debug2")
util.AddNetworkString("checksaum")
util.AddNetworkString("gcontrol_vars")
util.AddNetworkString("control_vars")

print("QAC: Serverside Starting")
QAC = true

-----------------------------  Config ----------------------------------\

local BanWhenDetected 	 = true 	-- Ban when detected?
local crash 			 = false 	-- Crashes when they are detected.
local whitelist			 = true 	-- Will use whitelist
local time 				 = 0 		-- Ban time
local banwait 			 = 1 		-- How long we delay the ban. No point in delaying it anymore, file stealer is removed.
local MaxPings 			 = 6 		-- Max pings they can not return
local KickForPings		 = false	-- If they exceed MaxPings

-------------------------------------------------------
-- Ban Systems ----------------------------------------
-- Do not set more than 1 to true. Only 1 at a time. --
-------------------------------------------------------

local UseSourceBans = false -- sm_ban
local UseAltSB 		= false -- ulx sban
local evolve        = false -- nigga do u use evolve as your admin mod
local serverguard   = false -- if you have serverguard... gay adminmod
local defaultBan    = true 	-- If all else fails, use this.

----------
-- Misc --
----------

local RepeatBan     = false -- Will ban them every time they're detected.
local E2Fix 		= false -- IF YOU USE E2 ON YOUR SERVER, USE THIS THANX. only shut off if you're having BD problemos
local banf 			= false -- !qac <name>. Set true to ban, false to steal only

------------------------------ End of Config --------------------------/


--------------------------------------------------------------------------------
--- DON'T TOUCH ANYTHING BELOW THIS POINT UNLESS YOU KNOW WHAT YOU'RE DOING-----
--------------------------------------------------------------------------------







-------------------
-- RunString Fix --
-------------------
oRunString = RunString
function RunString(var)
	//print("RunString ran with var: "..tostring(var))
	//error("RunString Callback: Contact ZTF")
	
	
	// fucknig runstring detour is useless
	if (E2Fix) then
		oRunString(var)
	end
end

 --[[
 To add more steamid's make sure the last steamid entry in the table doesnt have a comma at the end!
 All other entries should have one though!
 
 In otherwords, more steamid's would look like this!
 
 
	banned = {
	["STEAM_0:0:11101"] = true,
	["STEAM_0:0:11101"] = true,
	["STEAM_0:0:11101"] = true,
	["STEAM_0:0:11101"] = true,
	["STEAM_0:0:11101"] = true
	}


The last steamid shouldnt have a comma at the end! Thanks!

]]--


local banned = {} -- Dont touch this
 
if (whitelist) then
	banned = {
		["STEAM_0:0:11101"] = true
	}
end

-------------------
--- Ban function --
-------------------

local function Ban(p, r)
	print("Detected " .. p:Name() .. " for " .. r .. "(" .. p:SteamID() .. ")")
	
	if !(BanWhenDetected) then
		local qacrnb = "Detected " .. p:Name() .. " for " .. r .. "(" .. p:SteamID() .. ") \n"
		file.Append("QAC Log.txt", qacrnb)	
		return
	end
	
	-- Check whitelist
	if (banned[p:SteamID()]) then
		return
	end
	
	print("Banning " .. p:Name() .. " for " .. r .. "in " .. banwait .. " seconds.")
	
	-- Logging
	local qacr = "Banned " .. p:Name() .. " for " .. r .. "(" .. p:SteamID() .. ") \n"
	file.Append("QAC Log.txt", qacr)

	-- Repeat bans
	if !(RepeatBan) then
		banned[p:SteamID()] = true
	end
	
	-- Default, ulx ban + player:Ban()
	timer.Simple( banwait, function()
		if !(UseSourceBans) && !(UseAltSB) && (defaultBan) && !(serverguard) then
			p:Ban(time, r)
			RunConsoleCommand("ulx", "ban", p:Name() , time, r) -- So it shows up on ULX
			RunConsoleCommand("writeid")
		end
	end)
	
	-- serverguard
	timer.Simple( banwait, function()
		if !(UseSourceBans) && !(UseAltSB) && !(defaultBan) && !(serverguard) then
			RunConsoleCommand("serverguard_ban", p:Name() , 7000, r)
		end
	end)
	
	-- sm_ban
	timer.Simple( banwait, function()
		if (UseSourceBans) && !(UseAltSB) && !(defaultBan) && !(serverguard) then
			RunConsoleCommand("sm_ban", p:Name() , time, r)
		end
	end)
		
	-- ulx sban
	timer.Simple( banwait, function()
		if (UseAltSB) && !(UseSourceBans) && !(defaultBan) && !(serverguard) then
			RunConsoleCommand("ulx","sban", p:Name() , time, r)
		end
	end)
	
	--evolve
	timer.Simple( banwait, function()
		if !(UseAltSB) && !(UseSourceBans) && !(defaultBan) && !(serverguard) && (evolve) then
			RunConsoleCommand("ev", "ban", p:Name() , time, r)
		end
	end)
	
	--Crashing
	if (crash) then
	timer.Simple(banwait,function()
			p:SendLua("cam.End3D()")
			if (IsValid(p)) then
				p:Kick()
			end
		end)
	end
	
	 hook.Call("QACBan", GAMEMODE, p, r)
end



------------------------------
-- Foreign Source Detection --
------------------------------

local scans = {}

net.Receive(
	"checksaum",
	function(l, p)
		local s = net.ReadString()
		
		local sr = scans[s]
		local br = "Detected foreign source file " .. s .. "."
		
		if (sr != nil) then
			if (sr) then
				return
			else
				Ban(p, br)
			end
		end
		
		if (file.Exists(s, "game")) then
			scans[s] = true
		else
			scans[s] = false
			Ban(p, br)
		end
	end
)

----------------------
-- ConVar Detection --
----------------------

local ctd = {
	"sv_cheats",
	"sv_allowcslua",
	"mat_fullbright",
	"mat_proxy",
	"mat_wireframe",
	"host_timescale",
	"tmcb_allowcslua"
}

for i, c in pairs(ctd) do
	ctd[i] = GetConVar(c)
end

local function sendvars(p)
	for _, c in pairs(ctd) do
		net.Start("gcontrol_vars")
			net.WriteTable({c = c:GetName(), v = c:GetString()})
		net.Send(p)
	end
end

net.Receive(
	"gcontrol_vars",
	function(l, p)
		sendvars(p)
	end
)

local function validatevar(p, c, v)
	if (GetConVar(c):GetString() != (v || "")) then
		Ban(p, "Error: Cheat Detected: (" .. c .." = " .. v .. ")")
	end
end

net.Receive(
	"control_vars",
	function(l, p)
		local t = net.ReadTable()
		validatevar(p, t.c, t.v)
	end
)


-----------------
-- Ping system --
-----------------
if SERVER then

	print("QAC Ping starting")
	
	local CoNum = 2 -- dont change
	
	timer.Create("STC",10,0, function()
	for k, v in pairs(player.GetAll()) do
		--print("Sending ping!")
			net.Start("Debug2")
			net.WriteInt(CoNum, 10)
			--print("Sent! with # being " .. CoNum)
			if !v.Pings then 
				v.Pings = 0
			end
			if (KickForPings) then
				if v.Pings > MaxPings && !v:IsBot() then
					v:Kick("Not Ret")
					local retr = "Kicked " .. v:Name() .. " for  not returning our pings \n"
					file.Append("QAC Log.txt", retr)
					v.Pings = 0
				end
			end
			v.Pings = v.Pings + 1
			--print("Player has " .. v.Pings .." pings")
			net.Send(v)
			end
	end)
		
	net.Receive("Debug1", function(len, ply)
		local HNum = net.ReadInt(16)
		if (HNum) && HNum == CoNum  then
			--print("Player " .. ply:GetName() .. " returned! # is " .. HNum)	
			ply.Pings = ply.Pings - 1
		end
	end)
	
end

// ANTI SPEED HACK
local function NoSpeed(ply,data)
	if not ply.LastMove then
		ply.LastMove = 0
	end
	
	if ply.LastMove > 66 then
		local CurTime = CurTime()
		
		if ply.LastMoveClear and (CurTime - ply.LastMoveClear < 0.9) then
			data:SetMaxSpeed(0)
			data:SetForwardSpeed(0)
			data:SetUpSpeed(0)
			data:SetSideSpeed(0)
			data:SetMaxClientSpeed(0)
			-- fuck you guys hex said i dont care.
			-- mad.
			return data
		end
		
		ply.LastMove = 0
		ply.LastMoveClear = CurTime
	end
	ply.LastMove = ply.LastMove + 1
end
hook.Add("Move", "NoSpeed - QAC (but hex ty)", NoSpeed)
// If errors are caused, dont touch the hook, contact.


// NOPE

--[[
Possible fetch

http.fetch(blahlbalhl)

local numberversion = whatever

file.read(data/QACV.txt, GAME) etc etc

if number = data number then

print success

else  

print ur late faggot

Maybe autoupdate system? Dunno if I can write to lua

RunString() autoupdate checkversion.

]]--


--------
--ZTF --
--------