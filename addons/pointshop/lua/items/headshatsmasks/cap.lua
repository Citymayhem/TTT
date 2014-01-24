ITEM.Name = 'Graduation Cap'
ITEM.Price = 20000
ITEM.Model = 'models/player/items/humans/graduation_cap.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetModelScale(1.6, 0)
	model:SetMaterial('models/weapons/v_stunbaton/w_shaft01a')
	pos = pos + (ang:Forward() * -7) + (ang:Up() * 8)
	ang:RotateAroundAxis(ang:Right(), 90)

	return model, pos, ang
end
