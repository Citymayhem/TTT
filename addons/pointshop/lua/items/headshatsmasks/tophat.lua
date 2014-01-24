ITEM.Name = 'Owners Hat'
ITEM.Price = 0
ITEM.Model = 'models/player/items/humans/top_hat.mdl'
ITEM.AllowedUserGroups = {"superadmin"}

ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(0.8, 0)
	pos = pos + (ang:Forward() * -1) + (ang:Up() * 1)
	ang:RotateAroundAxis(ang:Right(), 20)
	
	return model, pos, ang
end

