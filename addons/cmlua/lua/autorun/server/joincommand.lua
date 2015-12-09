--[[ 
    
	-- How-to --
	Hi there! To make the code direct to your Steam group page or any page, change 
	the ADDRESS to for example: http://steamcommunity.com/groups/GROUPNAMEHERE/.
	
	Are you done? Good. If anyone in your server types !join it will refer them
	to your page and it will leave a chatmessage encouraging other players to join as well.
	
	-- Personal Notes --
	This simple code was made so server/community owners can let their players find their
	Steam group much easier. Unfortunately it's impossible(As far as I know) to make the
	players automatically join your Steam group because each player have individual 
	session IDs popping up when pressing the Join button.
	
	You can find me at http://artifia.net @ Avixia. Thanks!
	
--]]
function JoinCommand( pl, text, teamonly )
	if (text:lower() == "!join") then
		local url = "http://steamcommunity.com/groups/citymayhemofficial"
		for k, v in pairs(player.GetAll()) do v:ChatPrint( "Player " .. pl:Nick() .. " has joined our Steam group via !join." )end
		pl:SendLua("gui.OpenURL(\""..url.."\")")
	end
end
hook.Add( "PlayerSay", "joincommand", JoinCommand )