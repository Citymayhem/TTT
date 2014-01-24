    if SERVER then
       AddCSLuaFile( "shared.lua" )
       resource.AddFile("materials/VGUI/ttt/icon_cm2_tripmine.vmt")
    end
     
    SWEP.HoldType                           = "slam"
     
    if CLIENT then
     
       SWEP.PrintName    = "Tripwire Mine"
       SWEP.Slot         = 7
     
       SWEP.ViewModelFlip = true
       SWEP.ViewModelFOV                    = 64
       
       SWEP.EquipMenuData = {
          type = "item_weapon",
          desc = [[An explosive which is
		  placeable on walls, killing anyone
		  who walks through. This was
		  created by Prof. T. RipMyn.]]
       };
     
       SWEP.Icon = "VGUI/ttt/icon_cm2_tripmine"
    end
SWEP.Base = "weapon_tttbase"
	 
    SWEP.ViewModel                          = "models/weapons/v_slam.mdl"   -- Weapon view model
    SWEP.WorldModel                         = "models/weapons/w_slam.mdl"   -- Weapon world model
    SWEP.FiresUnderwater = false
     
    SWEP.Primary.Sound                      = Sound("")             -- Script that calls the primary fire sound
    SWEP.Primary.Delay                      = .5                    -- This is in Rounds Per Minute
    SWEP.Primary.ClipSize                   = 2             -- Size of a clip
    SWEP.Primary.DefaultClip                = 2             -- Bullets you start with
    SWEP.Primary.Automatic                  = false         -- Automatic = true; Semi Auto = false
    SWEP.Primary.Ammo                       = "slam"
	SWEP.LimitedStock = false
	
	SWEP.NoSights = true
     
    SWEP.AllowDrop = false
    SWEP.Kind = WEAPON_EQUIP2
    SWEP.CanBuy = {ROLE_TRAITOR}
     
    function SWEP:Deploy()
            self:SendWeaponAnim( ACT_SLAM_TRIPMINE_DRAW )
            return true
    end
     
    function SWEP:SecondaryAttack()
            return false
    end    
     
    function SWEP:OnRemove()
       if CLIENT and IsValid(self.Owner) and self.Owner == LocalPlayer() and self.Owner:Alive() then
          RunConsoleCommand("lastinv")
       end
    end
     
function SWEP:PrimaryAttack()
	self:TripMineStick()
	self.Weapon:EmitSound( Sound( "Weapon_SLAM.SatchelThrow" ) )
	self.Weapon:SetNextPrimaryFire(CurTime()+(self.Primary.Delay))
end
     
function SWEP:TripMineStick()
 if SERVER then
      local ply = self.Owner
      if not IsValid(ply) then return end
 
 
      local ignore = {ply, self.Weapon}
      local spos = ply:GetShootPos()
      local epos = spos + ply:GetAimVector() * 80
      local tr = util.TraceLine({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID})
 
      if tr.HitWorld then
         local mine = ents.Create("npc_tripmine")
         if IsValid(mine) then
 
            local tr_ent = util.TraceEntity({start=spos, endpos=epos, filter=ignore, mask=MASK_SOLID}, mine)
 
            if tr_ent.HitWorld then
 
               local ang = tr_ent.HitNormal:Angle()
               ang.p = ang.p + 90
 
               mine:SetPos(tr_ent.HitPos + (tr_ent.HitNormal * 3))
               mine:SetAngles(ang)
               mine:SetOwner(ply)
               mine:Spawn()
 
                                mine.fingerprints = self.fingerprints
								
                                self:SendWeaponAnim( ACT_SLAM_TRIPMINE_ATTACH )
                               
                                local holdup = self.Owner:GetViewModel():SequenceDuration()
                               
                                timer.Simple(holdup,
                                function()
                                if SERVER then
                                        self:SendWeaponAnim( ACT_SLAM_TRIPMINE_ATTACH2 )
                                end    
                                end)
                                       
                                timer.Simple(holdup + .1,
                                function()
                                        if SERVER then
                                                if self.Owner == nil then return end
                                                if self.Weapon:Clip1() == 0 && self.Owner:GetAmmoCount( self.Weapon:GetPrimaryAmmoType() ) == 0 then
                                                --self.Owner:StripWeapon(self.Gun)
                                                --RunConsoleCommand("lastinv")
												self:Remove()
                                                else
                                                self:Deploy()
                                                end
                                        end
                                end)
                       

                               --self:Remove()
                                self.Planted = true
								
	self:TakePrimaryAmmo( 1 )
                               
                        end
            end
         end
      end
end

function SWEP:Reload()
   return false
end