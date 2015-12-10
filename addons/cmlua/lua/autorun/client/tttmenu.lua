-- From the guide here- https://facepunch.com/showthread.php?t=1296365
-- Thanks an.droid
-- LocalPlayer = Player who clicked
-- menu.Player = Player clicked on

local panelfont = "HudHintTextLarge"
local panelpadding = 25
local panelitemmargin = 10

local durationtypes = {}
durationtypes['h'] = "Hours"
durationtypes['d'] = "Days"
durationtypes['w'] = "Weeks"
durationtypes['y'] = "Years"

--[[
===================================================================================================
Adds the right-click context menu to the TTT menu
===================================================================================================
--]]
hook.Add("TTTScoreboardMenu","cmscoreboardcontextmenu", function(menu)
	local ply = LocalPlayer()
	local target = menu.Player
	
	if not IsValid(target) then return end
	
	PlayClickSound()
	
	AddGeneralSection(menu)
	
	-- This check is here purely so we can add spacing between the admin and non-admin options
	-- There's a better way to do this, but I cba
	local minimumAdminGroup = "mod"
	if(ply:CheckGroup(minimumAdminGroup)) then
		menu:AddSpacer()
		AddAdminSections(menu)
	end
end)
--[[
===================================================================================================
--]]



--[[
===================================================================================================
Builds the right click menu
===================================================================================================
--]]

function AddGeneralSection(menu)	
	AddMenuOption(menu, "Copy Name", "icon16/user_edit.png", function(target) SetClipboardText( target:Nick() ) end )
	AddMenuOption(menu, "Copy SteamID", "icon16/tag_blue.png", function(target) SetClipboardText( target:SteamID() ) end )
	AddMenuOption(menu, "Open Profile", "icon16/world.png", function(target) target:ShowProfile() end )
end

function AddAdminSections(menu)

	AddRestrictedMenuOption(menu, "Spectate", "icon16/zoom.png", "ulx spectate", function(target) RunConsoleCommand("ulx","spectate", target:Nick() )  end )
	AddRestrictedMenuOption(menu, "Force Spectator", "icon16/status_offline.png", "ulx fspec", function(target) RunConsoleCommand("ulx","spec", target:Nick() )  end )
	
	menu:AddSpacer()
	
	AddRestrictedMenuOption(menu, "Teleport To", "icon16/arrow_up.png", "ulx goto", function(target) RunConsoleCommand("ulx","goto", target:Nick() )  end )
	AddRestrictedMenuOption(menu, "Bring (To where you're aiming)", "icon16/arrow_up.png", "ulx teleport", function(target) RunConsoleCommand("ulx","teleport", target:Nick() )  end )
	
	menu:AddSpacer()
	
	AddRestrictedMenuOption(menu, "Slay", "icon16/user_red.png", "ulx slay", function(target) RunConsoleCommand("ulx","slay", target:Nick() )  end )
	AddRestrictedMenuOption(menu, "Slay Next Round(s)", "icon16/clock_red.png", "ulx slaynr", function(target) RunConsoleCommand("ulx","slaynr", target:Nick() )  end )
	
	menu:AddSpacer()
	
	AddRestrictedMenuOption(menu, "Add Chat Message", "icon16/text_padding_bottom.png", "ulx tsay", function(target) ShowPrivateMessagePanel(target) end )
	AddRestrictedMenuOption(menu, "Private Message", "icon16/user_comment.png", "ulx psay", function(target) ShowPrivateMessagePanel(target)  end )
	AddRestrictedMenuOption(menu, "Gag", "icon16/sound_mute.png", "ulx gag", function(target) RunConsoleCommand("ulx","gag", target:Nick() )  end )
	AddRestrictedMenuOption(menu, "Ungag", "icon16/sound_low.png", "ulx ungag", function(target) RunConsoleCommand("ulx","ungag", target:Nick() )  end )
	AddRestrictedMenuOption(menu, "Mute", "icon16/comment_delete.png", "ulx mute", function(target) RunConsoleCommand("ulx","mute", target:Nick() )  end )
	AddRestrictedMenuOption(menu, "Unmute", "icon16/comment_add.png", "ulx unmute", function(target) RunConsoleCommand("ulx","unmute", target:Nick() )  end )
	
	menu:AddSpacer()
	
	AddRestrictedMenuOption(menu, "Kick", "icon16/door_in.png", "ulx kick", function(target) RunConsoleCommand("ulx","kick", "TODO" )  end )
	if ULib and ULib.ucl.query(ply,"ulx kick") then
		local kickmenu, kickmenuimg = menu:AddSubMenu("Kick")
			kickmenuimg:SetImage("icon16/error.png")
			AddMenuOption(kickmenu "RDM Warning", "", function(target) RunConsoleCommand("ulx","kick",target:Nick(),"RDM Warning")  end)
			AddMenuOption(kickmenu "Spamming", "", function(target) RunConsoleCommand("ulx","kick",target:Nick(),"Spamming")  end)
			AddMenuOption(kickmenu "Racism (Minor)", "", function(target) RunConsoleCommand("ulx","kick",target:Nick(),"Racism (Minor)")  end)
			AddMenuOption(kickmenu "Throwing Grenades Randomly", "", function(target) RunConsoleCommand("ulx","kick",target:Nick(),"Throwing Grenades Randomly")  end)
			AddMenuOption(kickmenu, "Other (specify)", "icon16/textfield.png", function(target) ShowKickReasonPanel(target) end)
	end
	
	AddRestrictedMenuOption(menu, "Ban", "icon16/cross.png", "ulx ban", function(target) RunConsoleCommand("ulx","ban", "TODO" )  end )
	if ULib and ULib.ucl.query(ply,"ulx ban") then
		local banmenu, banmenuimg = menu:AddSubMenu("Ban")
			local rdmmenu, rdmmenuimg = banmenu:AddSubMenu("RDM")
				rdmmenuimg:SetImage("icon16/bomb.png")
				AddMenuOption(rdmmenu "x2 (1 day)", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"1d","RDM x 2")  end)
				AddMenuOption(rdmmenu "x3 (2 days)", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"2d","RDM x 3")  end)
				AddMenuOption(rdmmenu "x4 (3 days)", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"3d","RDM x 4")  end)
				AddMenuOption(rdmmenu "x5 (4 days)", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"4d","RDM x 5")  end)
				AddMenuOption(rdmmenu "x6 (5 days)", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"5d","RDM x 6")  end)
				AddMenuOption(rdmmenu "7+ (perm)", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),0,"Mass RDM")  end)
			AddMenuOption(banmenu "Excessive Spam", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"1d","Excessive Spam")  end)
			AddMenuOption(banmenu "Inappropriate Spray", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"1d","Inappropriate Spray")  end)
			AddMenuOption(banmenu "Major Offensive Behaviour", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),0,"Major Offensive Behaviour")  end)
			AddMenuOption(banmenu "Random Nades", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),"2d","Throwing Grenades Randomly")  end)
			AddMenuOption(banmenu "Ghosting", "", function(target) RunConsoleCommand("ulx","ban",target:Nick(),0,"Ghosting")  end)
			AddMenuOption(banmenu, "Other (specify)", "icon16/textfield.png", function(target) ShowBanReasonPanel(target) end )
	end
end
--[[
===================================================================================================
--]]





--[[
===================================================================================================
Extra dialogs
===================================================================================================
--]]
function ShowPrivateMessagePanel (target)
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
		PlayClickSound()
		pmsgpanel:SetVisible(false)
	end
end
		
		
function ShowKickReasonPanel(target)
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
		PlayClickSound()
		krpanel:SetVisible(false)
	end
end


function ShowBanReasonPanel(target)
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
		local length, lengthmsg = ValidateBanLength(bltext:GetValue())
		if(length == nil)then surface.PlaySound("buttons/combine_button_locked.wav") bltext:RequestFocus() return end
		PlayClickSound()
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
			PlayClickSound()
		end
	end
end
--[[
===================================================================================================
--]]





--[[
===================================================================================================
Utility Functions
===================================================================================================
--]]
function PlayClickSound()
	surface.PlaySound("buttons/button9.wav")
end

function AddMenuOption(menu, text, iconImagePath, onClick)
	local target = menu.Player
	
	local onClickCallback = function()
		if IsValid(target) then
			onClick(target)
			PlayClickSound()
		end
	end
	
	menu:AddOption(text, onClickCallback):SetImage(iconImagePath)
end

function AddRestrictedMenuOption(menu, text, iconImagePath, requiredPermission, onClick)
	local ply = LocalPlayer() 
	
	if ULib and ULib.ucl.query(ply, requiredPermission)then
		AddMenuOption(menu, text, iconImagePath, onClick)
	end
end

-- When given a string as a time length, it will extract valid ban lengths
function ValidateBanLength(length)
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
--[[
===================================================================================================
--]]