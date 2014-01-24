
if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/VGUI/ttt/icon_cm_dualelites.vmt")
end
   
SWEP.HoldType = "pistol"
   

if CLIENT then
   SWEP.PrintName = "Dual Elites"
   SWEP.Slot = 1

   SWEP.Icon = "VGUI/ttt/icon_cm_dualelites"
end

SWEP.Kind = WEAPON_PISTOL

SWEP.Base = "weapon_tttbase"
SWEP.Primary.Recoil	= 2.5
SWEP.Primary.Damage = 18
SWEP.Primary.Delay = 0.12
SWEP.Primary.Cone = 0.07
SWEP.Primary.ClipSize = 30
SWEP.Primary.Automatic = true
SWEP.Primary.DefaultClip = 30
SWEP.Primary.ClipMax = 90
SWEP.Primary.Ammo = "Pistol"
SWEP.AutoSpawnable = true
SWEP.AmmoEnt = "item_ammo_pistol_ttt"

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 74
SWEP.ViewModel  = "models/weapons/v_pist_elite.mdl"
SWEP.WorldModel = "models/weapons/w_pist_elite.mdl"

SWEP.Primary.Sound = Sound( "Weapon_Elite.Single" )
SWEP.IronSightsPos = Vector(-0.1, 5, 2.799)
SWEP.IronSightsAng = Vector(0, 0, 0)
