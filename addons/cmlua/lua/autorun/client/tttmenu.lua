-- From the guide here- https://facepunch.com/showthread.php?t=1296365
-- Thanks an.droid
-- LocalPlayer = Player who clicked
-- menu.Player = Player clicked on

local panelfont = "HudHintTextLarge"
local panelpadding = 25
local panelitemmargin = 10

--[[
===================================================================================================
Adds the right-click context menu to the TTT menu
===================================================================================================
--]]
hook.Add("TTTScoreboardMenu","cmscoreboardcontextmenu", function(menu)
	local ply = LocalPlayer()
	local target = menu.Player
	
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
	AddPlayerMenuOption(menu, "Copy Name", "icon16/user_edit.png", function(target) SetClipboardText(target:Nick()) end)
	AddPlayerMenuOption(menu, "Copy SteamID", "icon16/tag_blue.png", function(target) SetClipboardText(target:SteamID()) end)
	AddPlayerMenuOption(menu, "Open Profile", "icon16/world.png", function(target) target:ShowProfile() end)
end

function AddAdminSections(menu)

	AddULibRestrictedPlayerMenuOption(menu, "Spectate", "icon16/zoom.png", "ulx spectate", function(target) RunConsoleCommand("ulx","spectate", target:Nick())  end)
	AddULibRestrictedPlayerMenuOption(menu, "Force Spectator", "icon16/status_offline.png", "ulx fspec", function(target) RunConsoleCommand("ulx","spec", target:Nick())  end)
	
	menu:AddSpacer()
	
	AddULibRestrictedPlayerMenuOption(menu, "Teleport To", "icon16/arrow_up.png", "ulx goto", function(target) RunConsoleCommand("ulx","goto", target:Nick())  end)
	AddULibRestrictedPlayerMenuOption(menu, "Bring (To where you're aiming)", "icon16/arrow_up.png", "ulx teleport", function(target) RunConsoleCommand("ulx","teleport", target:Nick())  end)
	
	menu:AddSpacer()
	
	AddULibRestrictedPlayerMenuOption(menu, "Slay", "icon16/user_red.png", "ulx slay", function(target) RunConsoleCommand("ulx","slay", target:Nick()) end)
	AddULibRestrictedPlayerMenuOption(menu, "Slay Next Round(s)", "icon16/clock_red.png", "ulx slaynr", function(target) RunConsoleCommand("ulx","slaynr", target:Nick())  end)
	
	menu:AddSpacer()
	
	AddULibRestrictedPlayerMenuOption(menu, "Private Message", "icon16/user_comment.png", "ulx psay", function(target) OpenPrivateMessageDialog(target) end)
	
	AddULibRestrictedPlayerMenuOption(menu, "Mute", "icon16/comment_delete.png", "ulx mute", function(target) RunConsoleCommand("ulx","mute", target:Nick())  end)
	AddULibRestrictedPlayerMenuOption(menu, "Unmute", "icon16/comment_add.png", "ulx unmute", function(target) RunConsoleCommand("ulx","unmute", target:Nick())  end)
	AddULibRestrictedPlayerMenuOption(menu, "Gag", "icon16/sound_mute.png", "ulx gag", function(target) RunConsoleCommand("ulx","gag", target:Nick())  end)
	AddULibRestrictedPlayerMenuOption(menu, "Ungag", "icon16/sound_low.png", "ulx ungag", function(target) RunConsoleCommand("ulx","ungag", target:Nick())  end)
	
	menu:AddSpacer()
	
	AddKickSubMenu(menu)
	
	menu:AddSpacer()
	
	AddBanSubMenu(menu)
end

function AddKickSubMenu(menu)
	-- If the player disconnects, this should fail gracefully. We need to record their name and steam Id in-case this happens for the error message
	local target = menu.Player
	local onPlayerDisconnect = function() LocalPlayer():ChatPrint(target:Nick() .. " (" .. target:SteamId() .. ") disconnected before you could kick them.") end

	local kickSubMenu = AddULibRestrictedSubMenu(menu, "Kick", "icon16/door_in.png", "ulx kick")
	
	if kickSubMenu == nil then return end
	
	AddMenuOption(kickSubMenu, "AFK", "", function(menu) 
		TryRunPlayerMenuOption(target, function(target) RunConsoleCommand("ulx", "kick", target:Nick(), "AFK") end, onPlayerDisconnect)
	end)
	AddMenuOption(kickSubMenu, "Final warning", "", function(menu)
		TryRunPlayerMenuOption(target, function(target) RunConsoleCommand("ulx", "kick", target:Nick(), "Final warning") end, onPlayerDisconnect)
	end)
	AddMenuOption(kickSubMenu, "Other (specify)", "icon16/textfield.png", function(menu)
		TryRunPlayerMenuOption(target, function(target) OpenKickReasonDialog(target, target:Nick(), onPlayerDisconnect) end, onPlayerDisconnect)
	end)
end

function AddBanSubMenu(menu)
	-- Even if the player disconnects, we want the ban to succeed
	local target = menu.Player
	local targetSteamId = target:SteamID()
	
	local banSubMenu = AddULibRestrictedSubMenu(menu, "Ban", "icon16/stop.png", "ulx banid")
	
	if banSubMenu == nil then return end
	
	AddMenuOption(banSubMenu, "Ghosting (Permanent)", "", function(target) RunConsoleCommand("ulx", "banid", targetSteamId, "1w", "Ghosting")  end )
	AddMenuOption(banSubMenu, "Hacking (Permanent)", "", function(target) RunConsoleCommand("ulx", "banid", targetSteamId, "1w", "Hacking")  end )
	AddMenuOption(banSubMenu, "Ignored previous warnings (1 week)", "", function(target) RunConsoleCommand("ulx", "banid", targetSteamId, "1w", "Ignored previous warnings")  end )
	AddMenuOption(banSubMenu, "Mass RDM (Permanent)", "", function(target) RunConsoleCommand("ulx", "ban", targetSteamId, "0", "Mass RDM")  end )
	AddMenuOption(banSubMenu, "Other (specify)", "icon16/textfield.png", function(menu) OpenBanPlayerDialog(target:Nick(), targetSteamId) end)
end
--[[
===================================================================================================
--]]





--[[
===================================================================================================
Dialog Functions
===================================================================================================
--]]
function OpenPrivateMessageDialog(target)
	local targetName = target:Nick()
	ShowMessagePanel("Private Message " .. targetName, "Enter a private message to send to " .. targetName, function(message)
		if IsValid(target) then
			RunConsoleCommand("ulx", "psay", target:Nick(), message)
			PlayClickSound()
		end
	end)
end

function OpenKickReasonDialog(target, targetName, failureCallback)
	ShowMessagePanel("", "Reason for kicking " .. targetName, function(reason)
		TryRunPlayerMenuOption(target, function(target) RunConsoleCommand("ulx", "kick", target:Nick(), reason) end, failureCallback)
	end) 
end

function OpenBanPlayerDialog(targetName, targetSteamId)
	ShowMessagePanel("Ban Length", "Length (minutes). 0 is permanent. Use h (hours), d (days) or w (weeks) for different lengths e.g. 1d = 1 day", function(banLength)
		
		local validBanLength = string.match(string.lower(string.Trim(banLength)), "^([0-9]+) *([mhdmy])$")
		if validBanLength then
			ShowMessagePanel("Ban Reason", "Reason for banning " .. targetName, function(reason)
				RunConsoleCommand("ulx", "banid", targetSteamId, banLength, reason)
				PlayClickSound()
			end)
		else
			-- TODO: Remove this recursion and handle this better
			LocalPlayer():ChatPrint("Invalid ban length.")
			OpenBanPlayerDialog(targetName, targetSteamId)
		end
	end)
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

function TryRunPlayerMenuOption(target, onSuccess, onError)	
	if IsValid(target) then
		onSuccess(target)
	else
		onError()
	end
end

function AddMenuOption(menu, text, iconImagePath, onClick)
	local menuOption = menu:AddOption(text, function() PlayClickSound() onClick(menu) end)
	
	if not (iconImagePath == "" or iconImagePath == nil) then 
		menuOption:SetImage(iconImagePath)
	end
end

function AddPlayerMenuOption(menu, text, iconImagePath, onClick)
	AddMenuOption(menu, text, iconImagePath, function()
		local target = menu.Player
		
		if IsValid(target) then
			onClick(target)
		end
	end)
end

function AddULibRestrictedPlayerMenuOption(menu, text, iconImagePath, requiredULibPermission, onClick)
	local ply = LocalPlayer() 
	
	if ULib and ULib.ucl.query(ply, requiredULibPermission) then
		AddPlayerMenuOption(menu, text, iconImagePath, onClick)
	end
end

function AddULibRestrictedSubMenu(menu, name, iconImagePath, requiredULibPermission)
	local ply = LocalPlayer()
	
	if not (ULib and ULib.ucl.query(ply, requiredULibPermission)) then
		return nil
	end
	
	local subMenu, parentMenuOption = menu:AddSubMenu(name)
	if not (iconImagePath == "" or iconImagePath == nil) then 
		parentMenuOption:SetImage(iconImagePath)
	end
	
	return subMenu
end

function ShowMessagePanel (panelTitle, inputLabel, successCallback)
	local curx = panelpadding
	local cury = panelpadding + panelitemmargin
	
	local pmsgpanel = vgui.Create("DFrame")
		pmsgpanel:SetTitle(panelTitle)
		pmsgpanel:ShowCloseButton(true)
		pmsgpanel:SetVisible(true)
		pmsgpanel:MakePopup()
		pmsgpanel:SetDraggable(true)
		
	local pmsglabel = vgui.Create("DLabel", pmsgpanel)
		pmsglabel:SetPos(curx,cury)
		pmsglabel:SetText(inputLabel)
		pmsglabel:SizeToContents()
	cury = cury + pmsglabel:GetTall() + panelitemmargin
	
	local pmsgtext = vgui.Create("DTextEntry", pmsgpanel)
		pmsgtext:SetPos(curx,cury)
		pmsgtext:SetTall(20)
		pmsgtext:SetWide(450)
		pmsgtext:SetEnterAllowed(true)
	
	pmsgpanel:SetSize(math.max(pmsglabel:GetSize(), pmsgtext:GetSize()) + panelpadding * 2, cury + pmsgtext:GetTall() + panelitemmargin)
	pmsgpanel:SetPos(ScrW() * 0.5 - (pmsgpanel:GetSize() / 2), ScrH() * 0.5 - (pmsgpanel:GetTall() / 2))
	-- center text box
	pmsgtext:SetPos(pmsgpanel:GetSize() / 2 - pmsgtext:GetSize() / 2, cury)
	
	pmsgtext:RequestFocus()
	
	pmsgtext.OnEnter = function()
		local message = pmsgtext:GetValue()
		if(message == "")then return end
		
		pmsgpanel:SetVisible(false)
		
		successCallback(message)
	end
end
--[[
===================================================================================================
--]]
