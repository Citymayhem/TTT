### /gamemodes/terrortown/gamemode/admin.lua ###
#### function PrintTraitors(ply) ####
	Replace
		if not IsValid(ply) or ply:IsSuperAdmin() then
	with
		if (not IsValid(ply)) or ply:IsSuperAdmin() or (ULib and ULib.ucl.query(ply,"ttt_print_traitors")) then
	Replace the "end" for this if statement with:
		elseif IsValid(ply) then pr("You do not appear to be RCON or an admin!") end
   

#### function PrintReport(ply) ####
	Replace
		 if not IsValid(ply) or ply:IsSuperAdmin() then
	with
		 if (not IsValid(ply)) or ply:IsSuperAdmin() or (ULib and ULib.ucl.query(ply,"ttt_print_adminreport")) then
		 

#### local function PrintKarma(ply) ####
	Replace
		if (not IsValid(ply)) or ply:IsSuperAdmin() then
	with
		if (not IsValid(ply)) or ply:IsSuperAdmin() or (ULib and ULib.ucl.query(ply,"ttt_print_karma")) then
		
		
#### local function PrintDamageLog(ply) ####
	Replace
		if (not IsValid(ply)) or ply:IsSuperAdmin() or GetRoundState() != ROUND_ACTIVE then
	with
		if (not IsValid(ply)) or ply:IsSuperAdmin() or GetRoundState() != ROUND_ACTIVE or (ULib and ULib.ucl.query(ply,"ttt_print_damagelog")) then


### /gamemodes/terrortown/entities/weapons/weapon_tttbase.lua ###
#### function SWEP:GetPrimaryCone() ####
	Add the following on the line before the return
	if self:GetIronsights() and self.Secondary.Cone then return self.Secondary.Cone  end
	
	
### /gamemodes/terrortown/entities/weapons/shared.lua ###
	Set SWEP.Primary.Damage to 9
	Set SWEP.Primary.Cone to 0.07
