if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType           = "ar2"

if CLIENT then
   SWEP.PrintName          = "Silenced Rifle"

   SWEP.Slot               = 6

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = [[A classic choice among traitors, 
	allowing long-range deaths in silence.]] // Yeah Mezz, I editted this <3
   };

   SWEP.Icon = "VGUI/ttt/icon_scout" // Good, no DLs <3
end


SWEP.Base               = "weapon_tttbase"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_EQUIP
SWEP.WeaponID = AMMO_RIFLE
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy

SWEP.Primary.Delay          = 1.5
SWEP.Primary.Recoil         = 3 // Edit: Less [suppress]
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "357_s"
SWEP.Primary.Damage = 50 // Edit: Less / aint hitman <3
SWEP.Primary.Cone = 0.000 // Oh GOD This is SO Boring. Please Kill Me this is massively OP
SWEP.Primary.ClipSize = 10
SWEP.Primary.ClipMax = 20 -- keep mirrored to ammo
SWEP.Primary.DefaultClip = 10

SWEP.HeadshotMultiplier = 5 // Boo yah 

SWEP.AutoSpawnable      = false
SWEP.AmmoEnt = "item_ammo_357_s"
SWEP.IsSilent = true

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel          = Model("models/weapons/cstrike/c_snip_sg550.mdl")
SWEP.WorldModel         = Model("models/weapons/w_snip_sg550.mdl")

SWEP.Primary.Sound = Sound("weapons/m4a1/m4a1-1.wav") // Stolen @ www.thepiratebay.se
SWEP.Primary.SoundLevel = 50

SWEP.Secondary.Sound = Sound("Default.Zoom")

SWEP.IronSightsPos      = Vector( 5, -15, -2 )
SWEP.IronSightsAng      = Vector( 2.6, 1.37, 3.5 )

SWEP.ZoomLevel = 0
SWEP.NextReload = CurTime() + 0.3

function SWEP:SetZoom(state)
    if CLIENT then 
       return
    elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
       if state then
	      if self.ZoomLevel == 0 then
              self.Owner:SetFOV(20, 0.3)
		  elseif self.ZoomLevel == 1 then
		      self.Owner:SetFOV(7, 0.3)
		  elseif self.ZoomLevel == 2 then
		      self.Owner:SetFOV(2, 0.3)
		  end
       else
          self.Owner:SetFOV(0, 0.2)
       end
    end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
    if self.Weapon:GetNextSecondaryFire() > CurTime() then return end
    
    bIronsights = not self:GetIronsights()
    
    self:SetIronsights( bIronsights )
	self.ZoomLevel = 0
    
    if SERVER then
        self:SetZoom(bIronsights)
     else
        self:EmitSound(self.Secondary.Sound)
    end
    
    self.Weapon:SetNextSecondaryFire( CurTime() + 0.3)
end

function SWEP:PreDrop()
    self:SetZoom(false)
    self:SetIronsights(false)
    return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
    if self:GetIronsights() && self.NextReload < CurTime() then
	    self.ZoomLevel = (self.ZoomLevel + 1)% 3
        self:SetZoom(true)
		self:EmitSound(self.Secondary.Sound)
	    self.NextReload = CurTime() + 1
	end
end


function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoom(false)
    return true
end

if CLIENT then
   local scope = surface.GetTextureID("sprites/scope")
   function SWEP:DrawHUD()
      if self:GetIronsights() then
         surface.SetDrawColor( 0, 0, 0, 255 )
         
         local x = ScrW() / 2.0
         local y = ScrH() / 2.0
         local scope_size = ScrH()

         -- crosshair
         local gap = 80
         local length = scope_size
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )

         gap = 0
         length = 50
         surface.DrawLine( x - length, y, x - gap, y )
         surface.DrawLine( x + length, y, x + gap, y )
         surface.DrawLine( x, y - length, x, y - gap )
         surface.DrawLine( x, y + length, x, y + gap )


         -- cover edges
         local sh = scope_size / 2
         local w = (x - sh) + 2
         surface.DrawRect(0, 0, w, scope_size)
         surface.DrawRect(x + sh - 2, 0, w, scope_size)

         surface.SetDrawColor( 0, 0, 255, 255) // A?
         surface.DrawLine(x, y, x + 1, y + 1)

         -- scope
         surface.SetTexture(scope)
         surface.SetDrawColor(255, 255, 255, 255)

         surface.DrawTexturedRectRotated(x, y, scope_size, scope_size, 0)

      else
         return self.BaseClass.DrawHUD(self)
      end
   end

   function SWEP:AdjustMouseSensitivity()
      return (self:GetIronsights() and 0.2) or nil
   end
end