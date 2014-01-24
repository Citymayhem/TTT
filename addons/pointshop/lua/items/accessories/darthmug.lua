ITEM.Name = 'Darth\'s Mug'
ITEM.Price = 0
ITEM.Model = 'models/props/cs_office/coffee_mug.mdl'
ITEM.Bone = 'ValveBiped.Bip01_R_Hand'


function ITEM:OnEquip(ply, modifications)
	ply:PS_AddClientsideModel(self.ID)
end

function ITEM:OnHolster(ply)
	ply:PS_RemoveClientsideModel(self.ID)
end

function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	pos = pos + (ang:Right() * 3.5) + (ang:Up() * 0) + (ang:Forward() * 4)
	ang:RotateAroundAxis(ang:Up(),180)
	ang:RotateAroundAxis(ang:Right(),180)
	ang:RotateAroundAxis(ang:Forward(),10)
	return model, pos, ang
end

function ITEM:CanPlayerBuy(ply)
	if(ply:SteamID() == "STEAM_0:0:47561415")then return true end
	return false
end
