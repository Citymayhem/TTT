---- Example TTT custom weapon

-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/VGUI/ttt/icon_cm930_aug.vmt")
end

if CLIENT then
   SWEP.PrintName = "AUG"
   SWEP.Slot      = 2

   SWEP.Icon = "VGUI/ttt/icon_cm930_aug"
end

SWEP.Base				= "weapon_tttbase"
SWEP.HoldType			= "ar2"

SWEP.Kind = WEAPON_HEAVY

SWEP.Primary.Delay       = 0.166667
SWEP.Primary.Recoil      = 1.4
SWEP.Primary.Automatic   = true
SWEP.Primary.Damage      = 27
SWEP.Primary.Cone        = 0.0232
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.ClipSize    = 30
SWEP.Primary.ClipMax     = 60
SWEP.Primary.DefaultClip = 30
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.UseHands			= true
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV  = 72
SWEP.ViewModel  = "models/weapons/v_rif_aug.mdl"
SWEP.WorldModel = "models/weapons/w_rif_aug.mdl"

SWEP.Primary.Sound       = Sound( "weapons/aug/aug-1.wav" )
SWEP.IsSilent = true

//SWEP.IronSightsPos = Vector( 4, 1, 2.5 )
//SWEP.IronSightsAng = Vector( 2.2, 4, 10 )
SWEP.IronSightsPos = Vector( 6.15, 0, 1)
SWEP.IronSightsAng = Vector( 0.7, 2.9, 10)

function SWEP:SetZoom(state) --lkvs
   if CLIENT then return end
   if not (IsValid(self.Owner) and self.Owner:IsPlayer()) then return end
   if state then --lkve
      self.Owner:SetFOV(35, 0.5)
   else
      self.Owner:SetFOV(0, 0.2)
   end
end

-- Add some zoom to ironsights for this gun
function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self.Weapon:GetNextSecondaryFire() > CurTime() then return end

   bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   if SERVER then
      self:SetZoom(bIronsights)
   end

   self.Weapon:SetNextSecondaryFire(CurTime() + 0.3)
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