local CATEGORY_NAME = "Other"

if SERVER then
	ULib.ucl.registerAccess("ulx seeallmaps","superadmin","See all available maps in the maps list, rather than only voteable ones.",CATEGORY_NAME)
else
	hook.Add("TTTScoreboardColorForPlayer","TTTAdminColours",function(ply)
		if(ply:SteamID() == "STEAM_0:0:30458122")then
			return Color(0,175,0,255)
		end
		local group = ply:GetUserGroup()
		if(group == "moderator" || group == "donator")then
			return Color(0,210,255,255)
		end
	end)
end