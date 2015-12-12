-- traitor equipment: c4 bomb

AddCSLuaFile( )

SWEP.HoldType			= "slam"

if CLIENT then
   SWEP.PrintName			= "C4"
   SWEP.Slot				= 6

   SWEP.EquipMenuData = {
      type  = "item_weapon",
      name  = "C4",
      desc  = "c4_desc"
   };

   SWEP.Icon = "vgui/ttt/icon_c4"
   SWEP.IconLetter = "I"
end

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR} -- only traitors can buy
SWEP.WeaponID = AMMO_C4

SWEP.UseHands			= true
SWEP.ViewModelFlip		= false
SWEP.ViewModelFOV		= 54
SWEP.ViewModel  = Model("models/weapons/cstrike/c_c4.mdl")
SWEP.WorldModel = Model("models/weapons/w_c4.mdl")

SWEP.DrawCrosshair      = false
SWEP.ViewModelFlip      = false
SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo       = "none"
SWEP.Primary.Delay = 5.0

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = true
SWEP.Secondary.Ammo     = "none"
SWEP.Secondary.Delay = 1.0

SWEP.NoSights = true

local throwsound = Sound( "Weapon_SLAM.SatchelThrow" )

function SWEP:PrimaryAttack()
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
   self:BombDrop()
end

function SWEP:SecondaryAttack()
   self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
   self:BombStick()
end

-- mostly replicating HL2DM slam throw here
function SWEP:BombDrop()
   if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      if self.Planted then return end

      local vsrc = ply:GetShootPos()
      local vang = ply:GetAimVector()
      local vvel = ply:GetVelocity()
      local vthrow = vvel + vang * 200

      local bomb = ents.Create("ttt_c4")
      if IsValid(bomb) then
         bomb:SetPos(vsrc + vang * 10)
         bomb:SetOwner(ply)
         bomb:SetThrower(ply)
         bomb:Spawn()

         bomb:PointAtEntity(ply)

         local ang = bomb:GetAngles()
         ang:RotateAroundAxis(ang:Up(), 180)
         bomb:SetAngles(ang)

         bomb.fingerprints = self.fingerprints

         bomb:PhysWake()
         local phys = bomb:GetPhysicsObject()
         if IsValid(phys) then
            phys:SetVelocity(vthrow)
         end
         self:Remove()

         self.Planted = true

      end

      ply:SetAnimation( PLAYER_ATTACK1 )
   end

   self:EmitSound(throwsound)
   self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end

-- again replicating slam, now its attach fn
function SWEP:BombStick()
   if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end

      if self.Planted then return end

      local ignore = {ply, self}
      local spos = ply:GetShootPos()
      local epos = spos + ply:GetAimVector() * 80
	  --BCODE
		local tr = util.TraceLine({start=spos, endpos=epos, filter=ply})
		local target = tr.Entity
		if target:IsWorld() or (target:IsPlayer() and ply:IsTraitor() and !target:IsTraitor()) then
			if(target:IsPlayer() and target.CarryingBomb)then ply:PrintMessage(HUD_PRINTTALK,"That player is already carrying C4!") return end
			local bomb = ents.Create("ttt_c4")
			if IsValid(bomb) then
				local pos, ang
				if target:IsWorld() then
					bomb:PointAtEntity(ply)
					local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, bomb)
					if tr_ent.HitWorld then
						--Pos and ang stuff
						ang = tr_ent.HitNormal:Angle()
						ang:RotateAroundAxis(ang:Right(), -90)
						ang:RotateAroundAxis(ang:Up(), 180)
						pos = tr_ent.HitPos
						--Wall stuff
						bomb.IsOnWall = true
						if(pos==nil)then 
							print("Failed to get world position...")
						end
					end
				else
					--Pos and ang stuff
					--target:SetModel("models/Player/combine_super_soldier.mdl")
					local bone = target:LookupBone("ValveBiped.Bip01_Spine")--target
					if(bone == nil)then
						ErrorNoHalt("Failed to get spine bone position for "..tostring(target:GetModel())) 
						pos = target:GetPos()
						ang = target:GetAngles()
						pos = pos + (ang:Up()*42)
						pos = pos + (ang:Forward()*-3)
						ang:RotateAroundAxis(ang:Forward(),90)
						ang:RotateAroundAxis(ang:Right(),90)
					else
						pos, ang = target:GetBonePosition(bone)
						pos = pos + (ang:Up()*2)
						ang:RotateAroundAxis(ang:Forward(),90)
						ang:RotateAroundAxis(ang:Up(),-90)
					end
					--Stuck to player stuff
					bomb:SetParent(target)
					bomb.IsOnPlayer = true
					bomb:SetPreventTransmit(target,true)--Prevents target player from seeing + using C4
					if(target:LookupAttachment("chest") == 0)then
						ErrorNoHalt("Failed to get chest attachment point for "..tostring(target:GetModel())) 
						if(bone != nil)then 
							bomb:FollowBone(target,bone) 
							pos, ang = target:GetBonePosition(bone)
							pos = pos + (ang:Up()*2)
							ang:RotateAroundAxis(ang:Forward(),180)
							ang:RotateAroundAxis(ang:Right(),0)
							ang:RotateAroundAxis(ang:Up(),180)
						end
					else
						bomb:Fire("setparentattachmentmaintainoffset", "chest", 0)--Follow player attachment
					end
					bomb.host = target
					target.CarryingBomb = true
				end
				bomb:SetPos(pos)
				bomb:SetAngles(ang)
				bomb:SetOwner(ply)
				bomb:SetThrower(ply)
				bomb:Spawn()
				bomb.fingerprints = self.fingerprints
				local phys = bomb:GetPhysicsObject()
				if IsValid(phys) then
					phys:EnableMotion(false)
				end
				self:Remove()
				self.Planted = true
			end
			ply:SetAnimation( PLAYER_ATTACK1 )
		end--END OF BCODE
   end
end


function SWEP:Reload()
   return false
end

function SWEP:OnRemove()
   if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
      RunConsoleCommand("lastinv")
   end
end
