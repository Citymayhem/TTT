if SERVER then
   AddCSLuaFile( "shared.lua" )
   
end

SWEP.HoldType			= "grenade"

if CLIENT then
   SWEP.PrintName	 = "Explosive Grenade"
   SWEP.Slot		 = 3

   SWEP.Icon = "VGUI/ttt/icon_nades"
end

SWEP.Base				= "weapon_tttbasegrenade"
SWEP.Spawnable = true
SWEP.AdminSpawnable = true

SWEP.Kind = WEAPON_NADE
SWEP.WeaponID = AMMO_MOLOTOV

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel			= "models/weapons/c_grenade.mdl"
SWEP.WorldModel			= "models/weapons/w_grenade.mdl"
SWEP.Weight			= 5
SWEP.AutoSpawnable      = true
-- really the only difference between grenade weapons: the model and the thrown
-- ent.

function SWEP:GetGrenadeName()
   return "ttt_explosivegrenade_proj"
end

