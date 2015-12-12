-- Original post http://facepunch.com/showthread.php?t=1341204&p=43469693&viewfull=1#post43469693
-- Credit to McSimp
local APIKey = "APIKEYGOESHERE" -- See http://steamcommunity.com/dev/apikey

local function HandleSharedPlayer(ply, lenderSteamID)
    print(string.format("FamilySharing: %s | %s has been lent Garry's Mod by %s", 
            ply:Nick(),
            ply:SteamID(),
            lenderSteamID
    ))

    if not (ULib and ULib.bans) then return end

    if ULib.bans[lenderSteamID] then
        ply:Kick("The account that lent you Garry's Mod is banned on this server")
    end
end

local function CheckFamilySharing(ply)
    http.Fetch(
        string.format("http://api.steampowered.com/IPlayerService/IsPlayingSharedGame/v0001/?key=%s&format=json&steamid=%s&appid_playing=4000",
            APIKey,
            ply:SteamID64()
        ),
        
        function(rawJSONBody)
            body = util.JSONToTable(rawJSONBody)

            if not body or not body.response or not body.response.lender_steamid then
                error(string.format("FamilySharing: Invalid Steam API response for %s | %s: \n\"rawJSONBody\"\n", ply:Nick(), ply:SteamID()))
            end

            local lender = body.response.lender_steamid
            if lender ~= "0" then
                HandleSharedPlayer(ply, util.SteamIDFrom64(lender))
            end
        end,
        
        function(code)
            error(string.format("FamilySharing: Failed API call for %s | %s (Error: %s)\n", ply:Nick(), ply:SteamID(), code))
        end
    )
end

hook.Add("PlayerAuthed", "CheckFamilySharing", CheckFamilySharing)