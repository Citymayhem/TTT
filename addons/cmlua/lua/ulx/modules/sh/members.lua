local CATEGORY_NAME = "User Management"

function promoteUser(calling_ply, target_ply)
	if !(target_ply:IsUserGroup("user"))then 
		ULib.tsayError(calling_ply,"That player is not a user.")
		return false
	end
	local userInfo = ULib.ucl.authed[ target_ply:UniqueID() ]

	local id = ULib.ucl.getUserRegisteredID( target_ply )
	if not id then id = target_ply:SteamID() end

	ULib.ucl.addUser( id, userInfo.allow, userInfo.deny, "member" )

	ulx.fancyLogAdmin( calling_ply, "#A promoted user #T to member", target_ply)
end

local promoteuser = ulx.command(CATEGORY_NAME,"ulx promoteuser",promoteUser,"!promoteuser")
promoteuser:addParam{type=ULib.cmds.PlayerArg}
promoteuser:defaultAccess("moderator")
promoteuser:help("Promotes a user to member rank.")