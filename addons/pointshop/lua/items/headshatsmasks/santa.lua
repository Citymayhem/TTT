ITEM.Name = 'Santa Hat'
ITEM.Price = 200
ITEM.Model = 'models/santa/santa.mdl'
ITEM.Attachment = 'eyes'

function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Forward() * -3.2) + (ang:Right() * -2)
	ang:RotateAroundAxis(ang:Up(), -90)
	
	return model, pos, ang
end

function ITEM:CanPlayerBuy(ply)
	return os.date("%m") == "12" and true or false, 'It\'s not winter!'
end
