/*
http://ttt.badking.net/guides/hooks
TTTScoreboardColorForPlayer (ply)
	return nil to keep default colour
TTTScoreboardColumns (pnl)
	pnl:AddColumn("Header", function(ply) return contents end)
TTTScoreboardMenu (menu)
	menu = DermaMenu()
	menu:AddOption("Name",function() do stuff end):SetImage(path)
*/
local rankcolours = {}
rankcolours["superadmin"] = Color( 196, 0, 170 )
rankcolours["admin"] = Color( 224, 127, 1 )
rankcolours["badmin"] = Color( 228, 188, 8 )
rankcolours["moderator"] = Color( 0, 210, 255 )
rankcolours["donator"] = Color( 222, 87, 87 )
rankcolours["developer"] = Color( 157, 186, 92 )
rankcolours["badmod"] = Color( 0, 210, 255 )
rankcolours["owner"] = Color( 255, 0, 0 )
rankcolours["member"] = Color( 255, 255, 255 )

local ranknames = {}
ranknames["member"] = "Member"
ranknames["owner"] = "Owner"
ranknames["developer"] = "Developer"
ranknames["superadmin"] = "S. Admin"
ranknames["donator"] = "Donator"
ranknames["badmin"] = "Admin"
ranknames["admin"] = "Admin"
ranknames["moderator"] = "Moderator"
ranknames["badmod"] = "Moderator"

local panelfont = "HudHintTextLarge"
local panelpadding = 25
local panelitemmargin = 10

local durationtypes = {}
durationtypes['h'] = "Hours"
durationtypes['d'] = "Days"
durationtypes['w'] = "Weeks"
durationtypes['y'] = "Years"

hook.Add("TTTScoreboardColorForPlayer","cmscoreboardcolour",function(ply)
	if(rankcolours[ply:GetUserGroup()] == nil)then
		return nil
	end
	return rankcolours[ply:GetUserGroup()]
end)

// Adds a rank column to the TTT menu
hook.Add("TTTScoreboardColumns","cmscoreboardrank",function(pnl)
	pnl:AddColumn("Rank",function(ply)
		--self:SetTextColor(rankcolours[ply:GetUserGroup()] or Color(255,255,255))
		if(ranknames[ply:GetUserGroup()] == nil)then return "User" end
		return ranknames[ply:GetUserGroup()]
	end, 500)
end)


// Adds the right-click context menu to the TTT menu
hook.Add("TTTScoreboardMenu","cmscoreboardcontextmenu",function(menu)
	if not menu.Player:IsValid() then return end
	
	surface.PlaySound("buttons/button9.wav")
	
	AddGeneralSection(menu)
	AddMiscAdminSection(menu)
	AddMessageAdminSection(menu)
	AddKickBanAdminSection(menu)
end)



function AddGeneralSection(menu)
	local ply = LocalPlayer() -- Player who right-clicked
	local target = menu.Player -- Player right clicked on
	menu:AddOption("Copy Name", function() SetClipboardText(target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/user_edit.png")
	menu:AddOption("Copy SteamID", function() SetClipboardText(target:SteamID()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/tag_blue.png")
	menu:AddOption("Open Profile", function() target:ShowProfile() surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/world.png")
	printspacer = true
end



function AddMiscAdminSection(menu)
	local ply = LocalPlayer() -- Player who right-clicked
	local target = menu.Player -- Player right clicked on
	-- True as soon as we print an option. Used to print out a spacer before the first option for this section
	local addedoption = false
	
	--Spectating
	if ULib and ULib.ucl.query(ply,"ulx spectate")then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Spectate", function () RunConsoleCommand("ulx","spectate",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/zoom.png")
	end
	--Goto
	if ULib and ULib.ucl.query(ply,"ulx goto") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Go To", function () RunConsoleCommand("ulx","goto",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/arrow_up.png")
	end
	--Bring
	if ULib and ULib.ucl.query(ply,"ulx teleport") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Bring (Where you're aiming)", function () RunConsoleCommand("ulx","teleport",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/arrow_down.png")
	end
	--Slap
	if ULib and ULib.ucl.query(ply,"ulx slap") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Slap", function () RunConsoleCommand("ulx","slap",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/arrow_out.png")
	end
	--Slay
	if ULib and ULib.ucl.query(ply,"ulx slay") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Slay", function () RunConsoleCommand("ulx","slay",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/cross.png")
	end
	--SlayNR
	if ULib and ULib.ucl.query(ply,"ulx slaynr") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Slay Next Round", function () RunConsoleCommand("ulx","slaynr",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/clock_red.png")
	end
	--Respawn
	if ULib and ULib.ucl.query(ply,"ulx respawn") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Respawn", function () RunConsoleCommand("ulx","respawn",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/heart.png")
	end
end



function AddMessageAdminSection(menu)
	local ply = LocalPlayer() -- Player who right-clicked
	local target = menu.Player -- Player right clicked on
	local addedoption = false -- True as soon as we print an option
	
	--Message
	if ULib and ULib.ucl.query(ply,"ulx psay") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Message", function ()
			-- Private message panel
			local curx = panelpadding
			local cury = panelpadding + panelitemmargin
			
			local pmsgpanel = vgui.Create("DFrame")
				pmsgpanel:SetTitle("Private Message " .. target:Nick())
				pmsgpanel:ShowCloseButton(true)
				pmsgpanel:SetVisible(true)
				pmsgpanel:MakePopup()
				pmsgpanel:SetDraggable(true)
				
			local pmsglabel = vgui.Create("DLabel", pmsgpanel)
				pmsglabel:SetPos(curx,cury)
				pmsglabel:SetText("Enter a private message to send to " .. target:Nick())
				pmsglabel:SizeToContents()
			cury = cury + pmsglabel:GetTall() + panelitemmargin
			
			local pmsgtext = vgui.Create("DTextEntry", pmsgpanel)
				pmsgtext:SetPos(curx,cury)
				pmsgtext:SetTall(20)
				pmsgtext:SetWide(450)
				pmsgtext:SetEnterAllowed(true)
			
			pmsgpanel:SetSize(math.max(pmsglabel:GetSize(), pmsgtext:GetSize()) + panelpadding * 2, cury + pmsgtext:GetTall() + panelitemmargin)
			pmsgpanel:SetPos(ScrW() * 0.5 - (pmsgpanel:GetSize() / 2), ScrH() * 0.5 - (pmsgpanel:GetTall() / 2))
			pmsgtext:SetPos(pmsgpanel:GetSize() / 2 - pmsgtext:GetSize() / 2, cury) -- center text box
			
			pmsgtext:RequestFocus()
			pmsgtext.OnEnter = function()
				local message = pmsgtext:GetValue()
				if(message == "")then return end
				RunConsoleCommand("ulx", "psay", target:Nick(), message)
				surface.PlaySound("buttons/button9.wav")
				pmsgpanel:SetVisible(false)
			end
		end):SetImage("icon16/comments.png")
	end
	--Mute
	if ULib and ULib.ucl.query(ply,"ulx mute") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Mute", function() RunConsoleCommand("ulx","mute",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/comment_delete.png")
	end
	--Unmute
	if ULib and ULib.ucl.query(ply,"ulx unmute") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Unmute", function() RunConsoleCommand("ulx","unmute",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/comment_add.png")
	end
	--Gag
	if ULib and ULib.ucl.query(ply,"ulx gag") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Gag", function() RunConsoleCommand("ulx","gag",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/sound_mute.png")
	end
	--Ungag
	if ULib and ULib.ucl.query(ply,"ulx ungag") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		menu:AddOption("Ungag", function() RunConsoleCommand("ulx","ungag",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/sound_low.png")
	end
end



function AddKickBanAdminSection(menu)
	local ply = LocalPlayer() -- Player who right-clicked
	local target = menu.Player -- Player right clicked on
	local addedoption = false -- True as soon as we print an option
	
	--Kick
	if ULib and ULib.ucl.query(ply,"ulx kick") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		local kickmenu, kickmenuimg = menu:AddSubMenu("Kick")
			kickmenuimg:SetImage("icon16/error.png")
			kickmenu:AddOption("RDM Warning", function() RunConsoleCommand("ulx","kick",target:Nick(),"RDM Warning") surface.PlaySound("buttons/button9.wav") end)
			kickmenu:AddOption("Spamming", function() RunConsoleCommand("ulx","kick",target:Nick(),"Spamming") surface.PlaySound("buttons/button9.wav") end)
			kickmenu:AddOption("Racism (Minor)", function() RunConsoleCommand("ulx","kick",target:Nick(),"Racism (Minor)") surface.PlaySound("buttons/button9.wav") end)
			kickmenu:AddOption("Throwing Grenades Randomly", function() RunConsoleCommand("ulx","kick",target:Nick(),"Throwing Grenades Randomly") surface.PlaySound("buttons/button9.wav") end)
			kickmenu:AddOption("Other (specify)", function ()
				--Our kick reason panel
				local curx = panelpadding
				local cury = panelpadding + panelitemmargin
				
				local krpanel = vgui.Create("DFrame")
					krpanel:SetTitle("Kick Reason")
					krpanel:ShowCloseButton(true)
					krpanel:SetVisible(true)
					krpanel:MakePopup()
					krpanel:SetDraggable(true)
				
				local krlabel = vgui.Create("DLabel", krpanel)-- Kick reason label
					krlabel:SetPos(curx,cury)
					krlabel:SetText("Enter a kick reason below (optional) and then press enter.")
					krlabel:SetFont(panelfont)
					krlabel:SizeToContents()
				cury = cury + krlabel:GetTall() + panelitemmargin
				
				local krtext = vgui.Create("DTextEntry", krpanel)--Our kick reason text box
					krtext:SetPos(curx,cury)
					krtext:SetTall(20)
					krtext:SetWide(450)
					krtext:SetEnterAllowed(true)
				
				krpanel:SetSize(math.max(krlabel:GetSize(), krtext:GetSize()) + panelpadding * 2, cury + krtext:GetTall() + panelitemmargin)
				krpanel:SetPos(ScrW() * 0.5 - (krpanel:GetSize() / 2), ScrH() * 0.5 - (krpanel:GetTall() / 2))
				krtext:SetPos(krpanel:GetSize() / 2 - krtext:GetSize() / 2, cury) -- center text box
				
				-- Text box processing
				krtext:RequestFocus()
				krtext.OnEnter = function()-- When the user presses enter or submits the kick reason
					RunConsoleCommand("ulx","kick",target:Nick(),krtext:GetValue())--We're allowing no reason to be specified
					surface.PlaySound("buttons/button9.wav")
					krpanel:SetVisible(false)
				end
			end):SetImage("icon16/textfield.png")
		-- end of kick sub-menu
	end
	
	--Ban
	if ULib and ULib.ucl.query(ply,"ulx ban") then
		if(not addedoption)then menu:AddSpacer() addedoption = true end
		local banmenu, banmenuimg = menu:AddSubMenu("Ban")
			banmenuimg:SetImage("icon16/stop.png")
			local rdmmenu, rdmmenuimg = banmenu:AddSubMenu("RDM")
				rdmmenuimg:SetImage("icon16/bomb.png")
				rdmmenu:AddOption("x2 (1 day)", function() RunConsoleCommand("ulx","ban",target:Nick(),"1d","RDM x 2") surface.PlaySound("buttons/button9.wav") end)
				rdmmenu:AddOption("x3 (2 days)", function() RunConsoleCommand("ulx","ban",target:Nick(),"2d","RDM x 3") surface.PlaySound("buttons/button9.wav") end)
				rdmmenu:AddOption("x4 (3 days)", function() RunConsoleCommand("ulx","ban",target:Nick(),"3d","RDM x 4") surface.PlaySound("buttons/button9.wav") end)
				rdmmenu:AddOption("x5 (4 days)", function() RunConsoleCommand("ulx","ban",target:Nick(),"4d","RDM x 5") surface.PlaySound("buttons/button9.wav") end)
				rdmmenu:AddOption("x6 (5 days)", function() RunConsoleCommand("ulx","ban",target:Nick(),"5d","RDM x 6") surface.PlaySound("buttons/button9.wav") end)
				rdmmenu:AddOption("7+ (perm)", function() RunConsoleCommand("ulx","ban",target:Nick(),0,"Mass RDM") surface.PlaySound("buttons/button9.wav") end)
			banmenu:AddOption("Excessive Spam", function() RunConsoleCommand("ulx","ban",target:Nick(),"1d","Excessive Spam") surface.PlaySound("buttons/button9.wav") end)
			banmenu:AddOption("Inappropriate Spray", function() RunConsoleCommand("ulx","ban",target:Nick(),"1d","Inappropriate Spray") surface.PlaySound("buttons/button9.wav") end)
			banmenu:AddOption("Major Offensive Behaviour", function() RunConsoleCommand("ulx","ban",target:Nick(),0,"Major Offensive Behaviour") surface.PlaySound("buttons/button9.wav") end)
			banmenu:AddOption("Random Nades", function() RunConsoleCommand("ulx","ban",target:Nick(),"2d","Throwing Grenades Randomly") surface.PlaySound("buttons/button9.wav") end)
			banmenu:AddOption("Ghosting", function() RunConsoleCommand("ulx","ban",target:Nick(),0,"Ghosting") surface.PlaySound("buttons/button9.wav") end)
			banmenu:AddOption("Other (specify)", function ()
				--Ban length panel
				local curx = panelpadding
				local cury = panelpadding + panelitemmargin
				
				local blpanel = vgui.Create("DFrame")
					blpanel:SetTitle("Ban Length")
					blpanel:SetVisible(true)
					blpanel:ShowCloseButton(true)
					blpanel:SetDraggable(true)
					blpanel:MakePopup()
				
				local bllabel = vgui.Create("DLabel",blpanel)
					bllabel:SetPos(curx,cury)
					bllabel:SetText("Enter a ban length and press enter. Enter 0 for a permanent ban.")
					bllabel:SetFont(panelfont)
					bllabel:SizeToContents()
				cury = cury + bllabel:GetTall() + panelitemmargin
				
				local bllabel2 = vgui.Create("DLabel",blpanel)
					local x,y = bllabel:GetPos()
					bllabel2:SetPos(curx,cury)
					bllabel2:SetText("Length is in minutes. Use h (hours), d (days) or w (weeks) for different lengths e.g. 1d = 1 day")
					bllabel2:SetFont(panelfont)
					bllabel2:SizeToContents()
				cury = cury + bllabel2:GetTall() + panelpadding
				
				local bltext = vgui.Create("DTextEntry", blpanel)-- Ban length text box
					bltext:SetPos(curx,cury)
					bltext:SetTall(20)
					bltext:SetWide(200)
					bltext:SetEnterAllowed(true)
				 
				-- Set our frame's size now that we know the size of its contents and center it
				blpanel:SetSize(math.max(bllabel:GetSize(), bllabel2:GetSize(), bltext:GetSize()) + panelpadding * 2, cury + bltext:GetTall() + panelitemmargin)
				blpanel:SetPos(ScrW() * 0.5 - (blpanel:GetSize() / 2), ScrH() * 0.5 - (blpanel:GetTall() / 2))
				bltext:SetPos(blpanel:GetSize() / 2 - bltext:GetSize() / 2, cury) -- center text box
				
				-- Text box processing
				bltext:RequestFocus() -- Set it as the focus
				bltext.OnEnter = function()--On submitting ban length
					-- Tidy up length string
					local length, lengthmsg = ValidateLength(bltext:GetValue())
					if(length == nil)then surface.PlaySound("buttons/combine_button_locked.wav") bltext:RequestFocus() return end
					surface.PlaySound("buttons/button9.wav")
					blpanel:SetVisible(false)
					
					-- Generate the menu
					local curx = panelpadding
					local cury = panelpadding + panelitemmargin
					
					local brpanel = vgui.Create("DFrame")--Ban reason panel
						brpanel:SetTitle("Ban Reason")
						brpanel:SetVisible(true)
						brpanel:ShowCloseButton(true)
						brpanel:MakePopup()
						brpanel:SetDraggable(true)
					
					local brlabellength = vgui.Create("DLabel",brpanel)
						brlabellength:SetPos(curx,cury)
						brlabellength:SetText("Ban length entered: " .. lengthmsg)
						brlabellength:SetFont(panelfont)
						brlabellength:SizeToContents()
					cury = cury + brlabellength:GetTall() + panelitemmargin
					
					local brlabel = vgui.Create("DLabel",brpanel)
						brlabel:SetPos(curx,cury)
						brlabel:SetText("Now enter a ban reason (required).")
						brlabel:SetFont(panelfont)
						brlabel:SizeToContents()
					cury = cury + brlabel:GetTall() + panelitemmargin
					
					local brtext = vgui.Create("DTextEntry",brpanel)--Ban reason text box
						brtext:SetPos(curx,cury)
						brtext:SetTall(20)
						brtext:SetWide(450)
						brtext:SetEnterAllowed(true)
					
					-- Set our frame's size now that we know the size of its contents and center it
					brpanel:SetSize(math.max(brlabellength:GetSize(), brlabel:GetSize(), brtext:GetSize()) + panelpadding * 2, cury + brtext:GetTall() + panelitemmargin)
					brpanel:SetPos(ScrW() * 0.5 - (brpanel:GetSize() / 2), ScrH() * 0.5 - (brpanel:GetTall() / 2))
					brtext:SetPos(brpanel:GetSize() / 2 - brtext:GetSize() / 2, cury) -- center text box
					
					brtext:RequestFocus()
					brtext.OnEnter = function()--On submitting reason
						local reason = brtext:GetValue()
						if(reason == "")then brtext:RequestFocus() return end -- Force them to either enter a reason or cancel the ban
						
						brpanel:SetVisible(false)							
						RunConsoleCommand("ulx","ban",target:Nick(),length,reason)
						surface.PlaySound("buttons/button9.wav")
					end
				end
			end):SetImage("icon16/textfield.png")
		-- End of ban sub menu
	end
end

// When given a string as a time length, it will extract valid ban lengths
function ValidateLength(length)
	length = string.gsub(length,"%s+","")
	if(length == "")then return nil end
	
	-- Generate a message to show on the menu based on the length
	local lengthmsg = nil
	if(tonumber(length))then
		if(tonumber(length) == 0)then lengthmsg = "permanent"
		else lengthmsg = length .. " minutes" end
	else
		local cleanlength = ""
		for duration,durationtype in string.gmatch(length,'([0-9]+)(%a)') do
			if(durationtypes[durationtype] == nil)then return nil end
			if(lengthmsg != nil)then lengthmsg = lengthmsg .. ", "
			else lengthmsg = "" end
			cleanlength = cleanlength .. duration .. durationtype
			lengthmsg = lengthmsg .. duration .. " " .. durationtypes[durationtype]
		end
		if(lengthmsg == nil)then return nil end
		length = cleanlength
	end
	
	return length, lengthmsg
end


/*





// Old code for colours & rank column
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


*/