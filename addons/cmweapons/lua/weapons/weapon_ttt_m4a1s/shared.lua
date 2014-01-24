---- Example TTT custom weapon

-- First some standard GMod stuff
if SERVER then
   AddCSLuaFile( "shared.lua" )
end
-- Made by SilentK, originally intended for CM.
if CLIENT then
   SWEP.PrintName = "M4A1-S"
   SWEP.Slot      = 6 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true
end

-- Always derive from weapon_tttbase.
SWEP.Base				= "weapon_tttbase"

--- Standard GMod values

SWEP.HoldType			= "ar2"

SWEP.Primary.Delay       = 0.09009 -- Very precise, huh? Actually is 0.0900900900907 IM SO SMART
SWEP.Primary.Recoil      = 0.858 -- as above
SWEP.Primary.Automatic   = true -- kinda obvious
SWEP.Primary.Damage      = 19 -- get stats from badger ###878 DONE LEL!!!
SWEP.Primary.Cone        = 0.01884 -- as above
SWEP.Primary.Ammo        = "Pistol"
SWEP.Primary.ClipSize    = 20
SWEP.Primary.ClipMax     = 60
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Sound = Sound( "weapons/m4a1/m4a1-1.wav" )
SWEP.ViewModelFlip = false
SWEP.HeadshotMultiplier = 2
SWEP.UseHands = true

//SWEP.IronSightsPos = Vector(-7.58, -9.2, 0.55) --set values, DO NOT FUCK WITH THESE BADGER
//SWEP.IronSightsAng = Vector(2.599, -1.3, -3.6) --set values, DO NOT FUCK WITH THESE BADGER
SWEP.NoSights = true //silenced weapons have an ironsites bug- position & angle screw up when you shoot


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
--[[function SWEP:SecondaryAttack()
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
end--]]

SWEP.ViewModel  = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1_silencer.mdl"


--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP1

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon. Of course this AK is special equipment so it won't,
-- but for the sake of example this is explicitly set to false anyway.
SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_TRAITOR }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil 

-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = false -- Not OP if you buy more than one, thus false.

-- If AllowDrop is false, players can't manually (MANUAL) drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = true -- like all silent weapons, this is true

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

-- Equipment menu information is only needed on the client
if CLIENT then
   -- Path to the icon material
   SWEP.Icon = "VGUI/ttt/icon_CM90288923r_m4a1s"

   -- Text shown in the equip menu
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = [["Invented by Prof. Emfowar, the 
	  M4A1-S is a silenced version of 
	  his other invention, the M4A1."]]
   };
end

-- Tell the server that it should download our icon to clients.
if SERVER then
   -- It's important to give your icon a unique name. GMod does NOT check for
   -- file differences, it only looks at the name. This means that if you have
   -- an icon_ak47, and another server also has one, then players might see the
   -- other server's dumb icon. Avoid this by using a unique name.
   resource.AddFile("materials/VGUI/ttt/icon_CM90288923r_m4a1s.vmt")
end

