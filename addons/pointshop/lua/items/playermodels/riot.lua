ITEM.Name = "Member- Riot"
ITEM.Price = 0
ITEM.Model = 'models/player/riot.mdl'

function ITEM:OnEquip(ply, modifications)
	if not ply._OldModel then
		ply._OldModel = ply:GetModel()
	end

	timer.Simple(1, function() ply:SetModel(self.Model) end)
end

function ITEM:OnHolster(ply)
	if ply._OldModel then
		ply:SetModel(ply._OldModel)
	end
end

function ITEM:PlayerSetModel(ply)
	ply:SetModel(self.Model)
end

function ITEM:CanPlayerBuy(ply)
	return !ply:IsUserGroup("user")
end