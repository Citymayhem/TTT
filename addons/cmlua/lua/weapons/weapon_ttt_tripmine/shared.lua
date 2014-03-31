    if SERVER then
       AddCSLuaFile( "shared.lua" )
       resource.AddFile("materials/VGUI/ttt/icon_cm2_tripmine.vmt")
    else
	hook.Add("PostDrawOpaqueRenderables","TTT_TripmineViewer",function()
		if LocalPlayer():GetRole() == ROLE_TRAITOR then
			local pos = LocalPlayer():EyePos()+LocalPlayer():EyeAngles():Forward()*10
			local ang = LocalPlayer():EyeAngles()
			ang = Angle(ang.p+90,ang.y,0)
			for k, v in pairs(ents.FindByClass("ttt_tripmine")) do
				render.ClearStencil()
				render.SetStencilEnable(true)
					render.SetStencilWriteMask(255)
					render.SetStencilTestMask(255)
					render.SetStencilReferenceValue(15)
					render.SetStencilFailOperation(STENCILOPERATION_REPLACE)
					render.SetStencilZFailOperation(STENCILOPERATION_REPLACE)
					render.SetStencilPassOperation(STENCILOPERATION_KEEP)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_ALWAYS)
					render.SetBlend(0)
					v:DrawModel()
					render.SetBlend(1)
					render.SetStencilCompareFunction(STENCILCOMPARISONFUNCTION_EQUAL)
					cam.Start3D2D(pos,ang,1)
							surface.SetDrawColor(255,0,0,255)
							surface.DrawRect(-ScrW(),-ScrH(),ScrW()*2,ScrH()*2)
					cam.End3D2D()
					v:DrawModel()
				render.SetStencilEnable(false)
			end
		end
	end)
end

SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "slam"


SWEP.UseHands      = true
SWEP.ViewModelFlip    = false
SWEP.ViewModelFOV    = 60
SWEP.ViewModel      = "models/weapons/c_slam.mdl"
SWEP.WorldModel = Model("models/weapons/w_slam.mdl")

SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false
SWEP.Primary.ClipSize       = 2
SWEP.Primary.DefaultClip    = 2
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "slam"
SWEP.Primary.Delay = 0.6

SWEP.AllowDrop = true

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.NoSights = true

if CLIENT then
   SWEP.PrintName			= "Tripwire Mine"
   SWEP.Slot				= 6

   SWEP.ViewModelFOV = 65
   
   SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "Tripmine",
      desc  = [[ Very explosive! ]]
   };

   SWEP.Icon = "VGUI/ttt/icon_cm2_tripmine"
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_DRAW)
	return true
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:Tripmine()
end

function SWEP:SecondaryAttack()
	return false
end
function SWEP:Tripmine()
	if SERVER then
		local ply = self.Owner
		if not IsValid(ply) then return end
		 local ignore = {ply, self.Weapon}
		 local spos = ply:GetShootPos()
		 local epos = spos + ply:GetAimVector() * 120
		 local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID})
		 if tr.HitWorld then
			local tripmine = ents.Create("ttt_tripmine")
			if IsValid(tripmine) then
				tripmine:PointAtEntity(ply)
				
				local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, tripmine)
				if tr_ent.HitWorld then
				local delay = 0.1
					self.Weapon:SendWeaponAnim(ACT_SLAM_TRIPMINE_ATTACH)
					timer.Simple(delay, function()
						if not IsValid(self) then return end
					
						local ang = tr_ent.HitNormal:Angle()
						ang:RotateAroundAxis(ang:Right(), -90)

						tripmine:SetPos(tr_ent.HitPos + tr_ent.HitNormal * 2)
						tripmine:SetAngles(ang)
						tripmine:SetPlacer(ply)
						tripmine:Spawn()
						
						tripmine.fingerprints = { ply }
						local del2 = self.Owner:GetViewModel():SequenceDuration()
						
						timer.Simple(del2,
						function()
							if SERVER then
								self:SendWeaponAnim( ACT_SLAM_TRIPMINE_ATTACH2)
							end
						end)
						
						timer.Simple(del2 + delay,
						function()
							if SERVER then
								if self.Owner == nil then return end
								if self.Weapon:Clip1() == 0 && self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) == 0 then
									self:Remove()
									else
									self:Deploy()
								end
							end
						end)
						self:EmitSound(Sound( "weapons/slam/mine_mode.wav" ))
						local nit = tripmine:GetPhysicsObject()
						if IsValid(nit) then
							nit:EnableMotion(false)
						end
						tripmine.IsOnWall = true
						self.Planted = true
						self:TakePrimaryAmmo( 1 )
					end)
				end
			end
			
			ply:SetAnimation( PLAYER_ATTACK1 )
		 end
	end
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end

function SWEP:Reload()
   return false
end

