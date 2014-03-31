/*  ___________________________________
---|                                  |--- 
---|   COKE                           |--- 
---|   FOR TROUBLE AND TERRORIST TOWN |--- 
---|                                  |--- 
---|                                  |--- 
---|                                  |--- 
---|    I always was bad at           |--- 
---|    ASCII Art ~ SilentK           |--- 
---|                                  |--- 
---|                                  |--- 
---|                                  |---
---|                                  |---
---|                                  |--- 
---|                                  |---
---|__________________________________|---
*/

//nearly all  made by Rejax, give creds to him <3
local COKE = {}
COKE.Colors = {}
COKE.Ranks = {}

// <config>

COKE.Colors["superadmin"] = Color( 196, 0, 170 )
COKE.Colors["admin"] = Color( 224, 127, 1 )
COKE.Colors["badmin"] = Color( 228, 188, 8 )
COKE.Colors["moderator"] = Color( 0, 210, 255 )
COKE.Colors["donator"] = Color( 222, 87, 87 )
COKE.Colors["developer"] = Color( 157, 186, 92 )
COKE.Colors["badmod"] = Color( 0, 210, 255 )
COKE.Colors["owner"] = Color( 255, 0, 0 )
COKE.Colors["member"] = Color( 255, 255, 255 )


COKE.Ranks["member"] = "Member"
COKE.Ranks["owner"] = "Owner"
COKE.Ranks["developer"] = "Developer"
COKE.Ranks["superadmin"] = "S. Admin"
COKE.Ranks["donator"] = "Donator"
COKE.Ranks["badmin"] = "Admin"
COKE.Ranks["admin"] = "Admin"
COKE.Ranks["moderator"] = "Moderator"
COKE.Ranks["badmod"] = "Moderator"

COKE.UseNameColors = true
COKE.NamePositioning = 5 -- EITHER FIVE, SIX OR SEVEN, DO NOT CHANGE OTHERWISE
COKE.CreateRankLabel = { enabled = true, text = "Rank" }

// </config>

local function MakeLabel( sb, text )
	for i = 1, COKE.NamePositioning do
		if ValidPanel(sb.cols[i]) then continue end
		sb.cols[i] = vgui.Create( "DLabel", sb )
		sb.cols[i]:SetText("")
	end
	sb.cols[COKE.NamePositioning] = vgui.Create( "DLabel", sb )
	sb.cols[COKE.NamePositioning]:SetText( text )
end

local function MakeRankText( sb, ply )

	local userGroup = ply:GetNWString( "usergroup" )
	local rankName = COKE.Ranks[userGroup]
	local rankColor = COKE.Colors[userGroup] or color_white
	local NamePositioning = COKE.NamePositioning
	
	for i = 1, NamePositioning-1 do
		if ValidPanel(sb.cols[i]) then continue end
		sb.cols[i] = vgui.Create( "DLabel", sb )
		sb.cols[i]:SetText("")
	end
	sb.cols[NamePositioning] = vgui.Create( "DLabel", sb )
	sb.cols[NamePositioning]:SetText( rankName )
	sb.cols[NamePositioning]:SetTextColor( rankColor )
	sb.cols[NamePositioning]:SetName( "COKEfor_"..ply:EntIndex() )

	local applySSettings = sb.ApplySchemeSettings
	sb.ApplySchemeSettings = function( self )
		applySSettings(self)
		self.cols[NamePositioning]:SetText( rankName )
		self.cols[NamePositioning]:SetTextColor( rankColor ) -- overwrite the given color
		self.cols[NamePositioning]:SetFont("treb_small")
	end
	
	local TTTcanfuckit = sb.LayoutColumns
	sb.LayoutColumns = function( self )
		TTTcanfuckit(self)
		local col = self.cols[NamePositioning]
	end
end

local function DoRankLabel( sb )
	for _, ply_group in ipairs( sb.ply_groups ) do
		for ply, row in pairs( ply_group.rows ) do
			if COKE.Ranks[ply:GetNWString("usergroup")] then
				MakeRankText( row, ply )
			end
		end
	end
end

local function COKE_Do()
--	if COKE.Created then return end

	GAMEMODE:ScoreboardCreate()
	
	local sb_main = GAMEMODE:GetScoreboardPanel()
	
	if COKE.CreateRankLabel.enabled then MakeLabel( sb_main, COKE.CreateRankLabel.text ) end
	DoRankLabel( sb_main )
	
--	COKE.Created = true
end
hook.Add( "ScoreboardShow", "EasyScoreboard_Show", COKE_Do )

local function AddNameColors( ply )
	local userGroup = ply:GetNWString( "usergroup" )
	if COKE.Colors[userGroup] and COKE.UseNameColors then
		return COKE.Colors[userGroup]
	else return color_white end
end
hook.Add( "TTTScoreboardColorForPlayer", "COKEColour", AddNameColors )