---- CL_QAC
---- CH 12/14/13, original copy @ 9/13
---- ZTF 
---- I don't care if you learn how to decrypt the lua cache and steal this, so stopping adding me about it
---- Tho pref dont redistribute ty

---- I like dicks.
--Source Detection ThingsQAC = true

// pls stop k00f
local nr = _G["net"]["Receive"]
local ns = _G["net"]["Start"]
local ns2s = _G["net"]["SendToServer"]
local nws = _G["net"]["WriteString"]
local nwi = _G["net"]["WriteInt"]
local nwt = _G["net"]["WriteTable"]
local nwb = _G["net"]["WriteBit"]
local nrt = _G["net"]["ReadTable"]
local cvarcb = cvars.AddChangeCallback

local scans = {}
local scanf = {
	{hook, "Add"},
	--{hook, "Call"}, -- cl deathnotice is retarded?  // needs to be fixed. -- esp
	--{hook, "Run"}, -- cl deathnotice is retarded?
	{timer, "Create"},
	{timer, "Simple"},
	--{_G, "CreateClientConVar"}, -- ULX IS GAY   // note to self, create detour
	--{_G, "RunString"}, -- cl deathnotice is retarded?
	--{_G, "RunStringEx"},
	
	{concommand, "Add"},
	{_G, "RunConsoleCommand"}

}

local function validate_src(src)
	ns("checksaum")
		nws(src)
	ns2s()
end
local function RFS()

	local CNum = net.ReadInt(10)
	
		ns("Debug1")
		
		nwi(CNum, 16)
		
		ns2s()
end

nr("Debug2", RFS)
local function scan_func()
	local s = {}
	
	for i = 0, 1/0, 1 do
	local dbg = debug.getinfo(i)
		
		if (dbg) then
			s[dbg.short_src] = true
		else
			break
		end
	end
	
	for src, _ in pairs(s) do
		if (src == "RunString" || src == "LuaCmd" || src == "[C]") then
			return
		elseif (!(scans[src])) then
			scans[src] = true
			validate_src(src)
		end
	end
end

---Scan Functions
local function SCAN_G()
	for _, ft in pairs(scanf) do
		local ofunc = ft[1][ft[2]]
		
		ft[1][ft[2]] = (
			function(...)
				local args = {...}
				scan_func()
				ofunc(unpack(args))
			end
		)
	end
end

hook.Add(
	"OnGamemodeLoaded",
	"___scan_g_init",
	function()
		SCAN_G()
		hook.Remove("OnGamemodeLoaded", "___scan_g_init")
	end
)


--ConVar Detection
local function validate_cvar(c, v)
	ns("control_vars")
		nwt({c = c, v = v})
	ns2s()
end


local function cvcc(cv, pval, nval)
	validate_cvar(cv, nval)
end

local ctd = {}

local function sned_req()
	ns("gcontrol_vars")
		nwb()
	ns2s()
end
_G.timer.Simple(1, sned_req)


nr(
	"gcontrol_vars",
	function()
		local t = nrt()
		
		local c = GetConVar(t.c)
		local v = c:GetString()
		ctd[c] = v
		
		cvarcb(t.c, cvcc)
		if (v != t.v) then
			validate_cvar(t.c, v)
		end
	end
)

---Timed Chec
local mintime = 010
local maxtime = 030

local function timecheck()
	for c, v in pairs(ctd) do
		local cv = c:GetString() || ""
		if (cv != v) then
			validate_cvar(c:GetName(), cv)
			ctd[c] = cv
		end
	end
	
	timer.Simple(math.random(mintime, maxtime), timecheck)
end

-- file steal pls REMOVED.
-- Not allowed. Sorry guys!
