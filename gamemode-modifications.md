/gamemodes/terrortown/gamemode/admin.lua
function PrintTraitors(ply)
	Replace
		if not IsValid(ply) or ply:IsSuperAdmin() then
	with
		if (not IsValid(ply)) or ply:IsSuperAdmin() or (ULib and ULib.ucl.query(ply,"ttt_print_traitors")) then
	Replace the "end" for this if statement with:
   else
      if IsValid(ply) then
         pr("You do not appear to be RCON or an admin!")
      end
   end
   

function PrintReport(ply)
	Replace
		 if not IsValid(ply) or ply:IsSuperAdmin() then
	with
		 if (not IsValid(ply)) or ply:IsSuperAdmin() or (ULib and ULib.ucl.query(ply,"ttt_print_adminreport")) then
		 

local function PrintKarma(ply)
	Replace
		if (not IsValid(ply)) or ply:IsSuperAdmin() then
	with
		if (not IsValid(ply)) or ply:IsSuperAdmin() or (ULib and ULib.ucl.query(ply,"ttt_print_karma")) then
		
		
local function PrintDamageLog(ply)
	Replace
		if (not IsValid(ply)) or ply:IsSuperAdmin() or GetRoundState() != ROUND_ACTIVE then
	with
		if (not IsValid(ply)) or ply:IsSuperAdmin() or GetRoundState() != ROUND_ACTIVE or (ULib and ULib.ucl.query(ply,"ttt_print_damagelog")) then
		
		
/gamemodes/terrortown/gamemode/player_ext.lua
Find and add a -- before the following line:
	hook.Call("PlayerSetModel", GAMEMODE, self)

	
/gamemodes/terrortown/gamemode/vgui/sb_row.lua
function PANEL:DoRightClick()
	Add the following code:
	surface.PlaySound("buttons/button9.wav")--Indicate the player has clicked on someone
	local ply = LocalPlayer()-- Player right clicking
	local target = self.Player-- Player right clicked on
	if not target:IsValid() then return end -- Shouldn't need to check but we will anyway
	if not ULib then return end-- Make sure ulib libraries are loaded
	local printspacer = false
	
	//Global options- available for all players
	local contextmenu = DermaMenu()// returns dmenu
		contextmenu:AddOption("Copy Name", function() SetClipboardText(target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/user_edit.png")
		contextmenu:AddOption("Copy SteamID", function() SetClipboardText(target:SteamID()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/tag_blue.png")
		contextmenu:AddOption("Open Profile", function() target:ShowProfile() surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/world.png")

		if ply:IsAdmin() or ply:IsSuperAdmin() or ply:CheckGroup("moderator") then // Used to add Spacer. Only needed if player has access to the following
			contextmenu:AddSpacer()
			--Misc
			--Spectating
			if ULib.ucl.query(ply,"ulx spectate")then
				contextmenu:AddOption("Spectate", function () RunConsoleCommand("ulx","spectate",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/zoom.png")
				printspacer = true
			end
			--Goto
			if ULib.ucl.query(ply,"ulx goto") then
				contextmenu:AddOption("Go To", function () RunConsoleCommand("ulx","goto",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/arrow_up.png")
				printspacer = true
			end
			--Bring
			if ULib.ucl.query(ply,"ulx teleport") then
				contextmenu:AddOption("Bring (Where you're aiming)", function () RunConsoleCommand("ulx","teleport",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/arrow_down.png")
				printspacer = true
			end
			--Slap
			if ULib.ucl.query(ply,"ulx slap") then
				contextmenu:AddOption("Slap", function () RunConsoleCommand("ulx","slap",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/arrow_out.png")
				printspacer = true
			end
			--Slay
			if ULib.ucl.query(ply,"ulx slay") then
				contextmenu:AddOption("Slay", function () RunConsoleCommand("ulx","slay",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/cross.png")
				printspacer = true
			end
			--SlayNR
			if ULib.ucl.query(ply,"ulx slaynr") then
				contextmenu:AddOption("Slay Next Round", function () RunConsoleCommand("ulx","slaynr",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/clock_red.png")
				printspacer = true
			end
			--Respawn
			if ULib.ucl.query(ply,"ulx respawn") then
				contextmenu:AddOption("Respawn", function () RunConsoleCommand("ulx","respawn",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/heart.png")
				printspacer = true
			end
			if(printspacer)then contextmenu:AddSpacer() printspacer = false end
			
			--Silencing
			--Message
			if ULib.ucl.query(ply,"ulx psay") then
				contextmenu:AddOption("Message", function () 
					local pmsgpanel = vgui.Create("DFrame")
						pmsgpanel:SetPos(ScrW() * 0.5 - 250, ScrH() * 0.5 - 40)
						pmsgpanel:SetSize(500,80)
						pmsgpanel:SetTitle("Private Message " .. target:Nick())
						pmsgpanel:ShowCloseButton(true)
						pmsgpanel:SetVisible(true)
						pmsgpanel:MakePopup()
						pmsgpanel:SetDraggable(true)
						
					local pmsglabel = vgui.Create("DLabel", pmsgpanel)
						pmsglabel:SetPos(25,30)
						pmsglabel:SetText("Enter a private message to send to " .. target:Nick())
						pmsglabel:SizeToContents()
					
					local pmsgtext = vgui.Create("DTextEntry", pmsgpanel)
						pmsgtext:SetPos(25,55)
						pmsgtext:SetTall(20)
						pmsgtext:SetWide(450)
						pmsgtext:SetEnterAllowed(true)
					pmsgtext.OnEnter = function()
						local message = pmsgtext:GetValue()
						if(message == "")then return end
						RunConsoleCommand("ulx", "psay", target:Nick(), message)
						surface.PlaySound("buttons/button9.wav")
						pmsgpanel:SetVisible(false)
					end
				end):SetImage("icon16/comments.png")
				printspacer = true
			end
			--Mute
			if ULib.ucl.query(ply,"ulx mute") then
				contextmenu:AddOption("Mute", function() RunConsoleCommand("ulx","mute",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/comment_delete.png")
				printspacer = true
			end
			--Unmute
			if ULib.ucl.query(ply,"ulx unmute") then
				contextmenu:AddOption("Unmute", function() RunConsoleCommand("ulx","unmute",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/comment_add.png")
				printspacer = true
			end
			--Gag
			if ULib.ucl.query(ply,"ulx gag") then
				contextmenu:AddOption("Gag", function() RunConsoleCommand("ulx","gag",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/sound_mute.png")
				printspacer = true
			end
			--Ungag
			if ULib.ucl.query(ply,"ulx ungag") then
				contextmenu:AddOption("Ungag", function() RunConsoleCommand("ulx","ungag",target:Nick()) surface.PlaySound("buttons/button9.wav") end):SetImage("icon16/sound_low.png")
				printspacer = true
			end
			if(printspacer)then contextmenu:AddSpacer() printspacer = false end
			
			--Kick
			if ULib.ucl.query(ply,"ulx kick") then
				local kickmenu, kickmenuimg = contextmenu:AddSubMenu("Kick")
					kickmenuimg:SetImage("icon16/error.png")
					kickmenu:AddOption("RDM Warning", function() RunConsoleCommand("ulx","kick",target:Nick(),"RDM Warning") surface.PlaySound("buttons/button9.wav") end)
					kickmenu:AddOption("Spamming", function() RunConsoleCommand("ulx","kick",target:Nick(),"Spamming") surface.PlaySound("buttons/button9.wav") end)
					kickmenu:AddOption("Racism (Minor)", function() RunConsoleCommand("ulx","kick",target:Nick(),"Racism (Minor)") surface.PlaySound("buttons/button9.wav") end)
					kickmenu:AddOption("Throwing Grenades Randomly", function() RunConsoleCommand("ulx","kick",target:Nick(),"Throwing Grenades Randomly") surface.PlaySound("buttons/button9.wav") end)
					kickmenu:AddOption("Other (specify)", function ()
						local krpanel = vgui.Create("DFrame")--Our kick reason panel
							krpanel:SetPos(ScrW() * 0.5 - 250, ScrH() * 0.5 - 40)
							krpanel:SetSize(500,80)
							krpanel:SetTitle("Kick Reason")
							krpanel:ShowCloseButton(true)
							krpanel:SetVisible(true)
							krpanel:MakePopup()
							krpanel:SetDraggable(true)
						
						local krlabel = vgui.Create("DLabel", krpanel)-- Kick reason label
							krlabel:SetPos(25,30)
							krlabel:SetText("Enter a kick reason below (optional) and then press enter.")
							krlabel:SizeToContents()
						
						local krtext = vgui.Create("DTextEntry", krpanel)--Our kick reason text box
							krtext:SetPos(25,55)
							krtext:SetTall(20)
							krtext:SetWide(450)
							krtext:SetEnterAllowed(true)
						krtext.OnEnter = function()-- When the user presses enter or submits the kick reason
							RunConsoleCommand("ulx","kick",target:Nick(),krtext:GetValue())--We're allowing no reason to be specified
							surface.PlaySound("buttons/button9.wav")
							krpanel:SetVisible(false)
						end
					end):SetImage("icon16/textfield.png")
				-- end of kick sub-menu
			end
			
			--Ban
			if ULib.ucl.query(ply,"ulx ban") then
				local banmenu, banmenuimg = contextmenu:AddSubMenu("Ban")
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
						local blpanel = vgui.Create("DFrame")--Ban length panel
							blpanel:SetPos(ScrW() * 0.5 - 250, ScrH() * 0.5 - 52.5)
							blpanel:SetSize(500,105)
							blpanel:SetTitle("Ban Length")
							blpanel:SetVisible(true)
							blpanel:ShowCloseButton(true)
							blpanel:SetDraggable(true)
							blpanel:MakePopup()
						
						local bllabel = vgui.Create("DLabel",blpanel)
							bllabel:SetPos(25,30)
							bllabel:SetText("Enter a ban length and press enter. Leave blank for a permanent ban.")
							bllabel:SizeToContents()
						
						local bllabel2 = vgui.Create("DLabel",blpanel)
							bllabel2:SetPos(25,55)
							bllabel2:SetText("Length is in minutes. Use h, d or w for hours, days or weeks e.g. 1d = 1 day")
							bllabel2:SizeToContents()
						
						local bltext = vgui.Create("DTextEntry", blpanel)-- Ban length text box
							bltext:SetPos(25,80)
							bltext:SetTall(20)
							bltext:SetWide(450)
							bltext:SetEnterAllowed(true)
						bltext.OnEnter = function()--On submitting ban length
							local length = bltext:GetValue()
							if(length == "")then length = 0 end -- assume that an empty length text box = perm ban
							blpanel:SetVisible(false)
							
							local brpanel = vgui.Create("DFrame")--Ban reason panel
								brpanel:SetPos(ScrW() * 0.5 - 250, ScrH() * 0.5 - 40)
								brpanel:SetSize(500,80)
								brpanel:SetTitle("Ban Reason")
								brpanel:SetVisible(true)
								brpanel:ShowCloseButton(true)
								brpanel:MakePopup()
								brpanel:SetDraggable(true)
							
							local brlabel = vgui.Create("DLabel",brpanel)
								brlabel:SetPos(25,30)
								brlabel:SetText("Ban length entered: " .. length .. ". Now enter a ban reason (required).")
								brlabel:SizeToContents()
							
							local brtext = vgui.Create("DTextEntry",brpanel)--Ban reason text box
								brtext:SetPos(25,55)
								brtext:SetTall(20)
								brtext:SetWide(450)
								brtext:SetEnterAllowed(true)
							brtext.OnEnter = function()--On submitting reason
								local reason = brtext:GetValue()
								if(reason == "")then return end -- Force them to either enter a reason or cancel the ban
								
								brpanel:SetVisible(false)							
								RunConsoleCommand("ulx","ban",target:Nick(),length,reason)
								surface.PlaySound("buttons/button9.wav")
							end
						end
					end):SetImage("icon16/textfield.png")
				-- End of ban sub menu
			end
		end
	contextmenu:Open()
	

/gamemodes/terrortown/entities/weapons/weapon_tttbase/shared.lua
function SWEP:GetPrimaryCone()
	Add the following on the line before the return
	if self:GetIronsights() and self.Secondary.Cone then return self.Secondary.Cone  end
	
	
/gamemodes/terrortown/entities/weapons/weapon_zm_sledge/shared.lua
	Set SWEP.Primary.Damage to 9
	Set SWEP.Primary.Cone to 0.07