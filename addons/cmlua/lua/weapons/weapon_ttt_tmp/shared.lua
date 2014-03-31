if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile("materials/VGUI/ttt/icon_cm_tmp.vmt")
end

SWEP.HoldType = "ar2"

if CLIENT then

   SWEP.PrintName = "TMP"
   SWEP.Slot = 6

   SWEP.Icon = "VGUI/ttt/icon_cm_tmp"
end


SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP1

SWEP.Primary.Damage      = 12
SWEP.Primary.Delay       = 0.065
SWEP.Primary.Cone        = 0.03
SWEP.Primary.ClipSize    = 30
SWEP.Primary.ClipMax     = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Automatic   = true
SWEP.Primary.Ammo        = "smg1"
SWEP.Primary.Recoil      = 1.15
SWEP.Primary.Sound       = Sound( "weapons/tmp/tmp-1.wav" )

SWEP.AutoSpawnable = true

SWEP.AmmoEnt = "item_ammo_smg1_ttt"

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel  = "models/weapons/cstrike/c_smg_tmp.mdl"
SWEP.WorldModel = "models/weapons/w_smg_tmp.mdl"

//SWEP.IronSightsPos = Vector(-6.3, -5, 3.5)
//SWEP.IronSightsAng = Vector(-2, 0.3, 6)
SWEP.NoSights = true //silenced weapons have an ironsites bug- position & angle screw up when you shoot

SWEP.DeploySpeed = 3

SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.LimitedStock = true

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()
   if not IsValid(att) then return 2 end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 150)

   -- decay from 3.2 to 1.7
   return 1.7 + math.max(0, (1.5 - 0.002 * (d ^ 1.25)))
end


