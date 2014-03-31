---- Example TTT custom weapon

-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/VGUI/ttt/scar-20.vmt")
end

if CLIENT then
   SWEP.PrintName = "SCAR-20"
   SWEP.Slot      = 6 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true
   SWEP.Icon = "VGUI/ttt/scar-20.vmt"
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = "A semi automatic sniper rifle."
   };
end

-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType			= "ar2"

SWEP.Primary.Delay       = 0.20996
SWEP.Primary.Recoil      = 1.587
SWEP.Primary.Automatic   = false
SWEP.Primary.Damage      = 31
SWEP.Primary.Cone        = 0.1
SWEP.Secondary.Cone        = 0.003
SWEP.Primary.Ammo        = "357"
SWEP.Primary.ClipSize    = 20
SWEP.Primary.ClipMax     = 40
SWEP.Primary.DefaultClip = 40
SWEP.Primary.Sound       = Sound( "scar20_unsil-1.wav" )
SWEP.HeadshotMultiplier  = 4

SWEP.Kind = WEAPON_EQUIP1
SWEP.AmmoEnt = "item_ammo_357_ttt"
SWEP.CanBuy = { ROLE_DETECTIVE, ROLE_TRAITOR }
SWEP.LimitedStock = true

SWEP.Secondary.Sound	 = Sound("Default.Zoom")

SWEP.IronSightsPos = Vector( 6.05, -5, 2.4 )
SWEP.IronSightsAng = Vector( 2.2, -0.1, 0 )

SWEP.ViewModel  = Model("models/weapons/v_snip_scar20.mdl")
SWEP.WorldModel = Model("models/weapons/w_snip_scar20.mdl")

function SWEP:SetZoom(state)
    if CLIENT then 
       return
    elseif IsValid(self.Owner) and self.Owner:IsPlayer() then
       if state then
          self.Owner:SetFOV(20, 0.3)
       else
          self.Owner:SetFOV(0, 0.2)
       end
    end
end

function SWEP:SecondaryAttack()
    if not self.IronSightsPos then return end
    if self.Weapon:GetNextSecondaryFire() > CurTime() then return end
    
    bIronsights = not self:GetIronsights()

	inverseIronsights = self:GetIronsights()
    
	self.Owner:DrawViewModel( inverseIronsights )

    self:SetIronsights( bIronsights )
    
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
    self.Weapon:DefaultReload( ACT_VM_RELOAD );
    self:SetIronsights( false )
    self:SetZoom(false)
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

         surface.SetDrawColor(255, 0, 0, 255)
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
	SWEP.Offset = {
		Pos = {
			Up = 0,
			Right = 1,
			Forward = -3,
		},
		Ang = {
			Up = 0,
			Right = 0,
			Forward = 0,
		}
	}
	--[[
	function SWEP:DrawWorldModel( )
		local hand, offset, rotate

		if not IsValid( self.Owner ) then
			self:DrawModel( )
			return
		end

		if not self.Hand then
			self.Hand = self.Owner:LookupAttachment( "anim_attachment_rh" )
		end

		hand = self.Owner:GetAttachment( self.Hand )

		if not hand then
			self:DrawModel( )
			return
		end

		offset = hand.Ang:Right( ) * self.Offset.Pos.Right + hand.Ang:Forward( ) * self.Offset.Pos.Forward + hand.Ang:Up( ) * self.Offset.Pos.Up

		hand.Ang:RotateAroundAxis( hand.Ang:Right( ), self.Offset.Ang.Right )
		hand.Ang:RotateAroundAxis( hand.Ang:Forward( ), self.Offset.Ang.Forward )
		hand.Ang:RotateAroundAxis( hand.Ang:Up( ), self.Offset.Ang.Up )

		self:SetRenderOrigin( hand.Pos + offset )
		self:SetRenderAngles( hand.Ang )

		self:DrawModel( )
	end--]]
end