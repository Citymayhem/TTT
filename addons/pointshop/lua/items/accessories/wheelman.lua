ITEM.Name = 'Wheelman'
ITEM.Price = 10000
ITEM.Model = 'models/xeon133/racewheel/race-wheel-30.mdl'
ITEM.Bone = 'ValveBiped.Bip01_Spine2'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.8, 0)
	pos = pos + (ang:Right() * 5) + (ang:Up() * 6) + (ang:Forward() * 2)

	return model, pos, ang
end
