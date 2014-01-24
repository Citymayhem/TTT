
---- Scoreboard player score row, based on sandbox version

include("sb_info.lua")


local GetTranslation = LANG.GetTranslation
local GetPTranslation = LANG.GetParamTranslation


SB_ROW_HEIGHT = 24 --16

local PANEL = {}

function PANEL:Init()
   -- cannot create info card until player state is known
   self.info = nil

   self.open = false

   self.cols = {}
   self.cols[1] = vgui.Create("DLabel", self)
   self.cols[1]:SetText(GetTranslation("sb_ping"))

   self.cols[2] = vgui.Create("DLabel", self)
   self.cols[2]:SetText(GetTranslation("sb_deaths"))

   self.cols[3] = vgui.Create("DLabel", self)
   self.cols[3]:SetText(GetTranslation("sb_score"))

   if KARMA.IsEnabled() then
      self.cols[4] = vgui.Create("DLabel", self)
      self.cols[4]:SetText(GetTranslation("sb_karma"))
   end

   for _, c in ipairs(self.cols) do
      c:SetMouseInputEnabled(false)
   end

   self.tag = vgui.Create("DLabel", self)
   self.tag:SetText("")
   self.tag:SetMouseInputEnabled(false)

   self.sresult = vgui.Create("DImage", self)
   self.sresult:SetSize(16,16)
   self.sresult:SetMouseInputEnabled(false)

   self.avatar = vgui.Create( "AvatarImage", self )
   self.avatar:SetSize(SB_ROW_HEIGHT, SB_ROW_HEIGHT)
   self.avatar:SetMouseInputEnabled(false)

   self.nick = vgui.Create("DLabel", self)
   self.nick:SetMouseInputEnabled(false)

   self.voice = vgui.Create("DImageButton", self)
   self.voice:SetSize(16,16)

   self:SetCursor( "hand" )
end


local namecolor = {
   default = COLOR_WHITE,
   admin = Color(220, 180, 0, 255),
   dev = Color(100, 240, 105, 255)
};

function GM:TTTScoreboardColorForPlayer(ply)
   if not IsValid(ply) then return namecolor.default end

   if ply:SteamID() == "STEAM_0:0:1963640" then
      return namecolor.dev
   elseif ply:IsAdmin() and GetGlobalBool("ttt_highlight_admins", true) then
      return namecolor.admin
   end
   return namecolor.default
end

local function ColorForPlayer(ply)
   if IsValid(ply) then
      local c = hook.Call("TTTScoreboardColorForPlayer", GAMEMODE, ply)

      -- verify that we got a proper color
      if c and type(c) == "table" and c.r and c.b and c.g and c.a then
         return c
      else
         ErrorNoHalt("TTTScoreboardColorForPlayer hook returned something that isn't a color!\n")
      end
   end
   return namecolor.default
end

function PANEL:Paint()
   if not IsValid(self.Player) then return end

--   if ( self.Player:GetFriendStatus() == "friend" ) then
--      color = Color( 236, 181, 113, 255 )
--   end

   local ply = self.Player

   if ply:IsTraitor() then
      surface.SetDrawColor(255, 0, 0, 30)
      surface.DrawRect(0, 0, self:GetWide(), SB_ROW_HEIGHT)
   elseif ply:IsDetective() then
      surface.SetDrawColor(0, 0, 255, 30)
      surface.DrawRect(0, 0, self:GetWide(), SB_ROW_HEIGHT)
   end


   if ply == LocalPlayer() then
      surface.SetDrawColor( 200, 200, 200, math.Clamp(math.sin(RealTime() * 2) * 50, 0, 100))
      surface.DrawRect(0, 0, self:GetWide(), SB_ROW_HEIGHT )
   end

   return true
end

function PANEL:SetPlayer(ply)
   self.Player = ply
   self.avatar:SetPlayer(ply)

   if not self.info then
      local g = ScoreGroup(ply)
      if g == GROUP_TERROR and ply != LocalPlayer() then
         self.info = vgui.Create("TTTScorePlayerInfoTags", self)
         self.info:SetPlayer(ply)

         self:InvalidateLayout()
      elseif g == GROUP_FOUND or g == GROUP_NOTFOUND then
         self.info = vgui.Create("TTTScorePlayerInfoSearch", self)
         self.info:SetPlayer(ply)
         self:InvalidateLayout()
      end
   else
      self.info:SetPlayer(ply)

      self:InvalidateLayout()
   end

   self.voice.DoClick = function()
                           if IsValid(ply) and ply != LocalPlayer() then
                              ply:SetMuted(not ply:IsMuted())
                           end
                        end

   self:UpdatePlayerData()
end

function PANEL:GetPlayer() return self.Player end

function PANEL:UpdatePlayerData()
   if not IsValid(self.Player) then return end

   local ply = self.Player
   self.cols[1]:SetText(ply:Ping())
   self.cols[2]:SetText(ply:Deaths())
   self.cols[3]:SetText(ply:Frags())

   if self.cols[4] then
      self.cols[4]:SetText(math.Round(ply:GetBaseKarma()))
   end

   self.nick:SetText(ply:Nick())
   self.nick:SizeToContents()
   self.nick:SetTextColor(ColorForPlayer(ply))

   local ptag = ply.sb_tag
   if ScoreGroup(ply) != GROUP_TERROR then
      ptag = nil
   end

   self.tag:SetText(ptag and GetTranslation(ptag.txt) or "")
   self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)

   self.sresult:SetVisible(ply.search_result != nil)

   -- more blue if a detective searched them
   if ply.search_result and (LocalPlayer():IsDetective() or (not ply.search_result.show)) then
      self.sresult:SetImageColor(Color(200, 200, 255))
   end

   -- cols are likely to need re-centering
   self:LayoutColumns()

   if self.info then
      self.info:UpdatePlayerData()
   end

   if self.Player != LocalPlayer() then
      local muted = self.Player:IsMuted()
      self.voice:SetImage(muted and "icon16/sound_mute.png" or "icon16/sound.png")
   else
      self.voice:Hide()
   end
end

function PANEL:ApplySchemeSettings()
   for k,v in pairs(self.cols) do
      v:SetFont("treb_small")
      v:SetTextColor(COLOR_WHITE)
   end

   self.nick:SetFont("treb_small")
   self.nick:SetTextColor(ColorForPlayer(self.Player))

   local ptag = self.Player and self.Player.sb_tag
   self.tag:SetTextColor(ptag and ptag.color or COLOR_WHITE)
   self.tag:SetFont("treb_small")

   self.sresult:SetImage("icon16/magnifier.png")
   self.sresult:SetImageColor(Color(170, 170, 170, 150))
end

function PANEL:LayoutColumns()
   for k,v in ipairs(self.cols) do
      v:SizeToContents()
      v:SetPos(self:GetWide() - (50*k) - v:GetWide()/2, (SB_ROW_HEIGHT - v:GetTall()) / 2)
   end

   self.tag:SizeToContents()
   self.tag:SetPos(self:GetWide() - (50 * 6) - self.tag:GetWide()/2, (SB_ROW_HEIGHT - self.tag:GetTall()) / 2)

   self.sresult:SetPos(self:GetWide() - (50*6) - 8, (SB_ROW_HEIGHT - 16) / 2)
end

function PANEL:PerformLayout()
   self.avatar:SetPos(0,0)
   self.avatar:SetSize(SB_ROW_HEIGHT,SB_ROW_HEIGHT)

   local fw = sboard_panel.ply_frame:GetWide()
   self:SetWide( sboard_panel.ply_frame.scroll.Enabled and fw-16 or fw )

   if not self.open then
      self:SetSize(self:GetWide(), SB_ROW_HEIGHT)

      if self.info then self.info:SetVisible(false) end
   elseif self.info then
      self:SetSize(self:GetWide(), 100 + SB_ROW_HEIGHT)

      self.info:SetVisible(true)
      self.info:SetPos(5, SB_ROW_HEIGHT + 5)
      self.info:SetSize(self:GetWide(), 100)
      self.info:PerformLayout()

      self:SetSize(self:GetWide(), SB_ROW_HEIGHT + self.info:GetTall())
   end

   self.nick:SizeToContents()

   self.nick:SetPos(SB_ROW_HEIGHT + 10, (SB_ROW_HEIGHT - self.nick:GetTall()) / 2)

   self:LayoutColumns()

   self.voice:SetVisible(not self.open)
   self.voice:SetSize(16, 16)
   self.voice:DockMargin(4, 4, 4, 4)
   self.voice:Dock(RIGHT)
end

function PANEL:DoClick(x, y)
   self:SetOpen(not self.open)
end

function PANEL:SetOpen(o)
   if self.open then
      surface.PlaySound("ui/buttonclickrelease.wav")
   else
      surface.PlaySound("ui/buttonclick.wav")
   end

   self.open = o

   self:PerformLayout()
   self:GetParent():PerformLayout()
   sboard_panel:PerformLayout()
end

function PANEL:DoRightClick()
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
			end
		end
	contextmenu:Open()
end

vgui.Register( "TTTScorePlayerRow", PANEL, "Button" )
