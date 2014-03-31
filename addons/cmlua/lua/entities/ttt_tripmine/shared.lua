if SERVER then
	AddCSLuaFile("shared.lua")
end

if CLIENT then
	ENT.Icon = "VGUI/ttt/icon_c4"
	ENT.PrintName = "Tripmine"
	ENT.Laser = Material( "cable/hydra" )
end

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_slam.mdl")

ENT.CanHavePrints = true
ENT.CanUseKey = true
ENT.Armed = false
ENT.BlastRadius = 300
ENT.BlastDamage = 1000

AccessorFunc( ENT, "Placer", "Placer" )
AccessorFuncDT( ENT, "disarmed", "Disarmed" )

function ENT:SetupDataTables()
   self:DTVar("Bool", 0, "disarmed")
end

function ENT:Initialize()
	if not IsValid(self) then return end
   self:SetModel(self.Model)
   self:PhysicsInit(SOLID_VPHYSICS)
   self:SetMoveType(MOVETYPE_NONE)
   self:SetSolid(SOLID_VPHYSICS)
   self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
   if SERVER then
		self:SetMaxHealth(10)
		self:SetUseType(SIMPLE_USE)
   end
    self:SetHealth(10)

    if not self:GetPlacer() then self:SetPlacer(nil) end
   
   self:SetDisarmed(false)
	self:SetBodygroup( 0, 1 )
	
   if SERVER then
	 self:SendWarn(true)
   end
   
   timer.Simple(1.5, function() if IsValid(self) then self:ActivateSLAM() end end)
end

function ENT:ActivateSLAM()
	if not IsValid(self) then return end

	local beam = self:GetAttachment( self:LookupAttachment("beam_attach") )
	self.beampos = beam.Pos
	
	local ceLine = util.QuickTrace(self.beampos, self:GetUp()*10000, self.Entity)
	self.LasLength = ceLine.Fraction
	self.LaserEndPos = ceLine.HitPos
	
	self.Armed = true
	
	if CLIENT then
		if LocalPlayer():IsTraitor() then
			for seik,shown in pairs(RADAR.bombs) do
				if seik == self:EntIndex() then 
					shown.beampos =  self.beampos
					shown.endpos = self.LaserEndPos
					break
				end
			end
		end
	
		local verif = tostring(self:EntIndex())
		hook.Add("PostDrawTranslucentRenderables", verif, function()
			if not IsValid(self) or self:GetDisarmed() then hook.Remove("PostDrawTranslucentRenderables", verif) end
			if self.Armed then
				render.SetMaterial( self.Laser )
				if LocalPlayer():HasWeapon("weapon_ttt_defuser") then
					render.DrawBeam( self.beampos, self.LaserEndPos, 3, 1, 1, Color( 255, 255, 255, 255 ) )
				else
					render.DrawBeam( self.beampos, self.LaserEndPos, 0.8, 1, 1, Color( 255, 255, 255, 50 ) )
				end
			end
		end)
	end
	
	if SERVER then
		sound.Play( Sound("weapons/c4/c4_beep1.wav"), self:GetPos(), 65, 110, 0.7)
	end
end

if SERVER then
function ENT:Defuse( gignstop )
	local counterterr = self:GetPlacer()
	self.Armed = false
	self:SetDisarmed( true )
	self:SetBodygroup( 0, 0 )
	if IsValid(counterterr) then
		LANG.Msg(counterterr, "Your tripmine was defused by " .. counterterr:Nick())
	end
	self:SendWarn(false)
end


function ENT:Think()
	if not IsValid(self) then return end

	if self.Armed then
		local lock = util.QuickTrace(self.beampos, self:GetUp()*10000, self)
			if lock.Fraction < self.LasLength and not self.exploding then
				self.exploding = true
				self:EmitSound( Sound("bot/aww_man.wav") )
			
				local counterterr = self:GetPlacer()
				if DMG_LOG and IsValid(lock.Entity) and lock.Entity:IsPlayer() then AddToDamageLog({DMG_LOG.SLAM_TRIP, lock.Entity:Nick(), lock.Entity:GetRoleString(), IsValid(counterterr) and counterterr:Nick() or "unknown", IsValid(counterterr) and counterterr:GetRoleString() or "traitor", {lock.Entity:SteamID(), counterterr:SteamID() or ""}}) end
			
				timer.Simple(0.1, function() if IsValid(self) then self:Explode() end end)
			end
			self:NextThink( CurTime() + 0.05 )
			return true
	end
end

end

function ENT:OnTakeDamage( dmginfo )
	if not IsValid(self) then return end
	if self.Exploding then return end
	if self:GetDisarmed() then
		util.EquipmentDestroyed(self:GetPos())
		self:Remove() 
		return 
	end

	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if self:Health() <= 0 then
		local fire = dmginfo:GetAttacker()
		local counterterr = self:GetPlacer()
		if DMG_LOG and IsValid(fire) and fire:IsPlayer() then AddToDamageLog({DMG_LOG.SLAM_DAMAGE, fire:Nick(), fire:GetRoleString(), counterterr:Nick() or "unknown", counterterr:GetRoleString() or "traitor", {fire:SteamID(), counterterr:SteamID() or ""}}) end
		
		self.exploding = true
		self:EmitSound( Sound("weapons/c4/c4_beep1.wav") )
		timer.Simple(0.1, function() if IsValid(self) then self:Explode() end end)
	end
end

function ENT:UseOverride(irfl)

if not IsValid(self) or self:GetDisarmed() then return end
	
   if IsValid(irfl) and irfl:IsPlayer() and not self.Exploding then
      local counterterr = self:GetPlacer() 
      if counterterr == irfl then
			if (not IsValid(irfl)) or (not irfl:IsTerror()) or (not irfl:Alive()) then return end
			
			if not irfl:CanCarryType(WEAPON_EQUIP1) then
				LANG.Msg(irfl, "This piece of equipment is too advanced for you.")
			else
				local educ = irfl:Give("weapon_ttt_tripmine")
				if IsValid(educ) then
				   educ.fingerprints = educ.fingerprints or {}
				   table.Add(educ.fingerprints, prints)

				    if self.beam != nil then
						self.beam:Remove()
					end
					if self.beamEnd != nil then
						self.beamEnd:Remove()
					end
					self:Remove()
				end
			end
      end
   end
end

function ENT:Explode()
	if not IsValid(self) or self.Exploding then return end
	
	self.Exploding = true
	
	local pos = self:GetPos()
	local radius = self.BlastRadius
	local damage = self.BlastDamage
	
	util.BlastDamage( self, self:GetPlacer(), pos, radius, damage )
	local deeff = EffectData()
		deeff:SetStart(pos)
		deeff:SetOrigin(pos)
		deeff:SetScale(radius)
		deeff:SetRadius(radius)
		deeff:SetMagnitude(damage)
	util.Effect("Explosion", deeff, true, true)
	
	sound.Play( Sound("c4.explode"), self:GetPos(), 77, 139 )
	self:Remove()
end

if SERVER then
   function ENT:SendWarn(DONE)
	if not IsValid(self) then return end
      umsg.Start("slam_warn", GetTraitorFilter(true))
		umsg.Short(self:EntIndex())
		umsg.Bool(DONE)
		umsg.Vector(self:GetPos())
      umsg.End()
   end

   function ENT:OnRemove()
		if not IsValid(self) then return end
		self:SendWarn(false)
   end
end