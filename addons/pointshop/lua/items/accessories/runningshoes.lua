ITEM.Name = 'Running Shoes'
ITEM.Price = 1000
ITEM.Model = 'models/xqm/jetengine.mdl'
ITEM.Bone = 'ValveBiped.Bip01_Spine2'
ITEM.Boost = 75
ITEM.trail = 'trails/smoke.vmt'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
	ply.RunningDustTrail = util.SpriteTrail(ply, 0, Color(255,93,0,255), false, 5,0.5, 5, 0.125, self.trail)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
	SafeRemoveEntity(ply.RunningDustTrail)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.5, 0)
	pos = pos + (ang:Right() * 7) + (ang:Forward() * 6)
	
	return model, pos, ang
end

function ITEM:Think(ply, modifications)
	if(!ply:IsOnGround())then return end
	if(ply:KeyDown(IN_FORWARD) and !ply:KeyDown(IN_BACK))then
		ply:SetVelocity(ply:GetForward() * self.Boost)
		if ply:KeyDown(IN_MOVERIGHT)then
			ply:SetVelocity(ply:GetRight() * self.Boost)
		end
		if ply:KeyDown(IN_MOVELEFT)then
			ply:SetVelocity(-ply:GetRight() * self.Boost)
		end
	end
end
