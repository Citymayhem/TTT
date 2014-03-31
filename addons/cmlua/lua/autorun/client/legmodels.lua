--[[
Allows players to see their character's legs
--]]


local Legs = CreateClientConVar( "cl_legs", "1", true, false )
local LegsBool = Legs:GetBool()

local Death = CreateClientConVar( "cl_deathview", "1", true, false )
local DeathBool = Death:GetBool()

local DeathFade = CreateClientConVar( "cl_deathfade", "0", true, false )
local DeathFadeBool = DeathFade:GetBool()

-- What is this for?
local Chat = CreateClientConVar( "cl_chat", "0", true, false )
local ChatBool = Chat:GetBool()

GMod_Legs_Ver = "3.5.1"

if LegsBool then
    local Legs = {}
    Legs.LegEnt = nil
     
    function ShouldDrawLegs()
        return  IsValid( Legs.LegEnt ) and
                ( LocalPlayer():Alive() or ( LocalPlayer().IsGhosted and LocalPlayer():IsGhosted() ) ) and
                !Legs:CheckDrawVehicle() and
                GetViewEntity() == LocalPlayer() and
                !LocalPlayer():ShouldDrawLocalPlayer() and
                !LocalPlayer():GetObserverTarget() and
                !LocalPlayer().ShouldDisableLegs
    end
     
    function GetPlayerLegs( ply )
        return ply and ply != LocalPlayer() and ply or ( ShouldDrawLegs() and Legs.LegEnt or LocalPlayer() )
    end
     
    Legs.FixedModelNames = {
        ["models/humans/group01/female_06.mdl"] = "models/player/group01/female_06.mdl",
        ["models/humans/group01/female_01.mdl"] = "models/player/group01/female_01.mdl",
        ["models/alyx.mdl"] = "models/player/alyx.mdl",
        ["models/humans/group01/female_07.mdl"] = "models/player/group01/female_07.mdl",
        ["models/charple01.mdl"] = "models/player/charple01.mdl",
        ["models/humans/group01/female_04.mdl"] = "models/player/group01/female_04.mdl",
        ["models/humans/group03/female_06.mdl"] = "models/player/group03/female_06.mdl",
        ["models/gasmask.mdl"] = "models/player/gasmask.mdl",
        ["models/humans/group01/female_02.mdl"] = "models/player/group01/female_02.mdl",
        ["models/gman_high.mdl"] = "models/player/gman_high.mdl",
        ["models/humans/group03/male_07.mdl"] = "models/player/group03/male_07.mdl",
        ["models/humans/group03/female_03.mdl"] = "models/player/group03/female_03.mdl",
        ["models/police.mdl"] = "models/player/police.mdl",
        ["models/breen.mdl"] = "models/player/breen.mdl",
        ["models/humans/group01/male_01.mdl"] = "models/player/group01/male_01.mdl",
        ["models/zombie_soldier.mdl"] = "models/player/zombie_soldier.mdl",
        ["models/humans/group01/male_03.mdl"] = "models/player/group01/male_03.mdl",
        ["models/humans/group03/female_04.mdl"] = "models/player/group03/female_04.mdl",
        ["models/humans/group01/male_02.mdl"] = "models/player/group01/male_02.mdl",
        ["models/kleiner.mdl"] = "models/player/kleiner.mdl",
        ["models/humans/group03/female_01.mdl"] = "models/player/group03/female_01.mdl",
        ["models/humans/group01/male_09.mdl"] = "models/player/group01/male_09.mdl",
        ["models/humans/group03/male_04.mdl"] = "models/player/group03/male_04.mdl",
        ["models/player/urban.mbl"] = "models/player/urban.mdl",
        ["models/humans/group03/male_01.mdl"] = "models/player/group03/male_01.mdl",
        ["models/mossman.mdl"] = "models/player/mossman.mdl",
        ["models/humans/group01/male_06.mdl"] = "models/player/group01/male_06.mdl",
        ["models/humans/group03/female_02.mdl"] = "models/player/group03/female_02.mdl",
        ["models/humans/group01/male_07.mdl"] = "models/player/group01/male_07.mdl",
        ["models/humans/group01/female_03.mdl"] = "models/player/group01/female_03.mdl",
        ["models/humans/group01/male_08.mdl"] = "models/player/group01/male_08.mdl",
        ["models/humans/group01/male_04.mdl"] = "models/player/group01/male_04.mdl",
        ["models/humans/group03/female_07.mdl"] = "models/player/group03/female_07.mdl",
        ["models/humans/group03/male_02.mdl"] = "models/player/group03/male_02.mdl",
        ["models/humans/group03/male_06.mdl"] = "models/player/group03/male_06.mdl",
        ["models/barney.mdl"] = "models/player/barney.mdl",
        ["models/humans/group03/male_03.mdl"] = "models/player/group03/male_03.mdl",
        ["models/humans/group03/male_05.mdl"] = "models/player/group03/male_05.mdl",
        ["models/odessa.mdl"] = "models/player/odessa.mdl",
        ["models/humans/group03/male_09.mdl"] = "models/player/group03/male_09.mdl",
        ["models/humans/group01/male_05.mdl"] = "models/player/group01/male_05.mdl",
        ["models/humans/group03/male_08.mdl"] = "models/player/group03/male_08.mdl",
        ["models/monk.mdl"] = "models/player/monk.mdl",
        ["models/eli.mdl"] = "models/player/eli.mdl",
    }
     
    function Legs:FixModelName( mdl )
        mdl = mdl:lower()
        return self.FixedModelNames[ mdl ] or mdl
    end

    function Legs:SetUp()
        self.LegEnt = ClientsideModel( Legs:FixModelName( LocalPlayer():GetModel() ), RENDER_GROUP_OPAQUE_ENTITY )
        self.LegEnt:SetNoDraw( true )
        self.LegEnt:SetSkin( LocalPlayer():GetInfoNum( "cl_playerskin", 0 ) )
        self.LegEnt:SetMaterial( LocalPlayer():GetMaterial() )
        self.LegEnt:SetColor( LocalPlayer():GetColor() )
				local groups = LocalPlayer():GetInfo( "cl_playerbodygroups" );
		if ( groups == nil ) then groups = "" end
		local groups = string.Explode( " ", groups )
		for k = 0, LocalPlayer():GetNumBodyGroups() - 1 do
			self.LegEnt:SetBodygroup( k, tonumber( groups[ k + 1 ] ) or 0 )
		end
		self.LegEnt.GetPlayerColor = function() 
			return Vector( GetConVarString( "cl_playercolor" ) ) 
		end
		self.LegEnt.LastTick = 0
    end
     
     
    Legs.PlaybackRate = 1
    Legs.Sequence = nil
    Legs.Velocity = 0
    Legs.OldWeapon = nil
    Legs.HoldType = nil
     
    Legs.BoneHoldTypes = { ["none"] = {
                                "ValveBiped.Bip01_Head1",
                                "ValveBiped.Bip01_Neck1",
                                "ValveBiped.Bip01_Spine4",
                                "ValveBiped.Bip01_Spine2",
                            },
                            ["default"] = {
                                "ValveBiped.Bip01_Head1",
                                "ValveBiped.Bip01_Neck1",
                                "ValveBiped.Bip01_Spine4",
                                "ValveBiped.Bip01_Spine2",
                                "ValveBiped.Bip01_L_Hand",
                                "ValveBiped.Bip01_L_Forearm",
                                "ValveBiped.Bip01_L_Upperarm",
                                "ValveBiped.Bip01_L_Clavicle",
                                "ValveBiped.Bip01_R_Hand",
                                "ValveBiped.Bip01_R_Forearm",
                                "ValveBiped.Bip01_R_Upperarm",
                                "ValveBiped.Bip01_R_Clavicle",
                                "ValveBiped.Bip01_L_Finger4",
                                "ValveBiped.Bip01_L_Finger41",
                                "ValveBiped.Bip01_L_Finger42",
                                "ValveBiped.Bip01_L_Finger3",
                                "ValveBiped.Bip01_L_Finger31",
                                "ValveBiped.Bip01_L_Finger32",
                                "ValveBiped.Bip01_L_Finger2",
                                "ValveBiped.Bip01_L_Finger21",
                                "ValveBiped.Bip01_L_Finger22",
                                "ValveBiped.Bip01_L_Finger1",
                                "ValveBiped.Bip01_L_Finger11",
                                "ValveBiped.Bip01_L_Finger12",
                                "ValveBiped.Bip01_L_Finger0",
                                "ValveBiped.Bip01_L_Finger01",
                                "ValveBiped.Bip01_L_Finger02",
                                "ValveBiped.Bip01_R_Finger4",
                                "ValveBiped.Bip01_R_Finger41",
                                "ValveBiped.Bip01_R_Finger42",
                                "ValveBiped.Bip01_R_Finger3",
                                "ValveBiped.Bip01_R_Finger31",
                                "ValveBiped.Bip01_R_Finger32",
                                "ValveBiped.Bip01_R_Finger2",
                                "ValveBiped.Bip01_R_Finger21",
                                "ValveBiped.Bip01_R_Finger22",
                                "ValveBiped.Bip01_R_Finger1",
                                "ValveBiped.Bip01_R_Finger11",
                                "ValveBiped.Bip01_R_Finger12",
                                "ValveBiped.Bip01_R_Finger0",
                                "ValveBiped.Bip01_R_Finger01",
                                "ValveBiped.Bip01_R_Finger02"
                            },
                            ["vehicle"] = {
                                "ValveBiped.Bip01_Head1",
                                "ValveBiped.Bip01_Neck1",
                                "ValveBiped.Bip01_Spine4",
                                "ValveBiped.Bip01_Spine2",
                            }
                        }
                     
    Legs.BonesToRemove = {}
    Legs.BoneMatrix = nil
     
    function Legs:WeaponChanged( weap )
        if IsValid( self.LegEnt ) then
            if IsValid( weap ) then
                self.HoldType = weap:GetHoldType()
            else
                self.HoldType = "none"
            end
     
            for boneId = 0, self.LegEnt:GetBoneCount() do
                self.LegEnt:ManipulateBoneScale(boneId, Vector(1,1,1))
                self.LegEnt:ManipulateBonePosition(boneId, Vector(0,0,0))
            end
     
            Legs.BonesToRemove = {
                "ValveBiped.Bip01_Head1"
            }
            if !LocalPlayer():InVehicle() then
                Legs.BonesToRemove = Legs.BoneHoldTypes[ Legs.HoldType ] or Legs.BoneHoldTypes[ "default" ]
            else
                Legs.BonesToRemove = Legs.BoneHoldTypes[ "vehicle" ]
            end
            for _, v in pairs( Legs.BonesToRemove ) do
                local boneId = self.LegEnt:LookupBone(v)
                if boneId then
                    self.LegEnt:ManipulateBoneScale(boneId, vector_origin)
                    self.LegEnt:ManipulateBonePosition(boneId, Vector(-10,-10,0))
                end
            end
        end
    end
     
    Legs.BreathScale = 0.5
    Legs.NextBreath = 0
     
    function Legs:Think( maxseqgroundspeed )
		if not LocalPlayer():Alive() then
			Legs:SetUp()
			return;
		end
			
        if IsValid( self.LegEnt ) then
			
            if LocalPlayer():GetActiveWeapon() != self.OldWeapon then
                self.OldWeapon = LocalPlayer():GetActiveWeapon()
                self:WeaponChanged( self.OldWeapon )
            end

                     
            if self.LegEnt:GetModel() != self:FixModelName( LocalPlayer():GetModel() ) then
                self.LegEnt:SetModel( self:FixModelName( LocalPlayer():GetModel() ) )
            end
             
            self.LegEnt:SetMaterial( LocalPlayer():GetMaterial() )
            self.LegEnt:SetSkin( LocalPlayer():GetSkin() )
     
            self.Velocity = LocalPlayer():GetVelocity():Length2D()
             
            self.PlaybackRate = 1
     
            if self.Velocity > 0.5 then
                if maxseqgroundspeed < 0.001 then
                    self.PlaybackRate = 0.01
                else
                    self.PlaybackRate = self.Velocity / maxseqgroundspeed
                    self.PlaybackRate = math.Clamp( self.PlaybackRate, 0.01, 10 )
                end
            end
             
            self.LegEnt:SetPlaybackRate( self.PlaybackRate )
             
            self.Sequence = LocalPlayer():GetSequence()
             
            if ( self.LegEnt.Anim != self.Sequence ) then
                self.LegEnt.Anim = self.Sequence
                self.LegEnt:ResetSequence( self.Sequence )
            end
             
            self.LegEnt:FrameAdvance( CurTime() - self.LegEnt.LastTick )
            self.LegEnt.LastTick = CurTime()
             
            Legs.BreathScale = sharpeye and sharpeye.GetStamina and math.Clamp( math.floor( sharpeye.GetStamina() * 5 * 10 ) / 10, 0.5, 5 ) or 0.5
             
            if Legs.NextBreath <= CurTime() then
                Legs.NextBreath = CurTime() + 1.95 / Legs.BreathScale
                self.LegEnt:SetPoseParameter( "breathing", Legs.BreathScale )
            end
             
            self.LegEnt:SetPoseParameter( "move_x", ( LocalPlayer():GetPoseParameter( "move_x" ) * 2 ) - 1 )
            self.LegEnt:SetPoseParameter( "move_y", ( LocalPlayer():GetPoseParameter( "move_y" ) * 2 ) - 1 )
            self.LegEnt:SetPoseParameter( "move_yaw", ( LocalPlayer():GetPoseParameter( "move_yaw" ) * 360 ) - 180 )
            self.LegEnt:SetPoseParameter( "body_yaw", ( LocalPlayer():GetPoseParameter( "body_yaw" ) * 180 ) - 90 )
            self.LegEnt:SetPoseParameter( "spine_yaw",( LocalPlayer():GetPoseParameter( "spine_yaw" ) * 180 ) - 90 )
             
            if ( LocalPlayer():InVehicle() ) then
                self.LegEnt:SetColor( color_transparent )
                self.LegEnt:SetPoseParameter( "vehicle_steer", ( LocalPlayer():GetVehicle():GetPoseParameter( "vehicle_steer" ) * 2 ) - 1 )
            end
        end
    end
     
    hook.Add( "UpdateAnimation", "Legs:UpdateAnimation", function( ply, velocity, maxseqgroundspeed )
        if ply == LocalPlayer() then
            if IsValid( Legs.LegEnt ) then
                Legs:Think( maxseqgroundspeed )
            else
                Legs:SetUp()
            end
        end
    end )
     
    Legs.RenderAngle = nil
    Legs.BiaisAngle = nil
    Legs.RadAngle = nil
    Legs.RenderPos = nil
    Legs.RenderColor = {}
    Legs.ClipVector = vector_up * -1
    Legs.ForwardOffset = -24
     
    function Legs:CheckDrawVehicle()
        return LocalPlayer():InVehicle()
    end
     
    hook.Add( "RenderScreenspaceEffects", "Legs:Render", function()
        cam.Start3D( EyePos(), EyeAngles() )
            if ShouldDrawLegs() then
             
                Legs.RenderPos = LocalPlayer():GetPos()
                if LocalPlayer():InVehicle() then
                    Legs.RenderAngle = LocalPlayer():GetVehicle():GetAngles()
                    Legs.RenderAngle:RotateAroundAxis( Legs.RenderAngle:Up(), 90 )
                else
                    Legs.BiaisAngles = sharpeye_focus and sharpeye_focus.GetBiaisViewAngles and sharpeye_focus:GetBiaisViewAngles() or LocalPlayer():EyeAngles()
                    Legs.RenderAngle = Angle( 0, Legs.BiaisAngles.y, 0 )
                    Legs.RadAngle = math.rad( Legs.BiaisAngles.y )
                    Legs.ForwardOffset = -22
                    Legs.RenderPos.x = Legs.RenderPos.x + math.cos( Legs.RadAngle ) * Legs.ForwardOffset
                    Legs.RenderPos.y = Legs.RenderPos.y + math.sin( Legs.RadAngle ) * Legs.ForwardOffset
                     
                    if LocalPlayer():GetGroundEntity() == NULL then
                        Legs.RenderPos.z = Legs.RenderPos.z + 8
                        if LocalPlayer():KeyDown( IN_DUCK ) then
                            Legs.RenderPos.z = Legs.RenderPos.z - 28
                        end
                    end
                end
                 
                Legs.RenderColor = LocalPlayer():GetColor()
                 
                local bEnabled = render.EnableClipping( true )
                    render.PushCustomClipPlane( Legs.ClipVector, Legs.ClipVector:Dot( EyePos() ) ) 
                        render.SetColorModulation( Legs.RenderColor.r / 255, Legs.RenderColor.g / 255, Legs.RenderColor.b / 255 )
                            render.SetBlend( Legs.RenderColor.a / 255 )
                                hook.Call( "PreLegsDraw", GAMEMODE, Legs.LegEnt )       
                                    Legs.LegEnt:SetRenderOrigin( Legs.RenderPos )
                                    Legs.LegEnt:SetRenderAngles( Legs.RenderAngle )
                                    Legs.LegEnt:SetupBones()
                                    Legs.LegEnt:DrawModel()
                                    Legs.LegEnt:SetRenderOrigin()
                                    Legs.LegEnt:SetRenderAngles()
                                hook.Call( "PostLegsDraw", GAMEMODE, Legs.LegEnt )
                            render.SetBlend( 1 )
                        render.SetColorModulation( 1, 1, 1 )
                    render.PopCustomClipPlane()
                render.EnableClipping( bEnabled )
            end
        cam.End3D()
    end )
end   


local function CalcView( ply, origin, angles, fov )
    if DeathBool then
        if( !LocalPlayer():GetRagdollEntity() || LocalPlayer():GetRagdollEntity() == NULL || !LocalPlayer():GetRagdollEntity():IsValid() ) then return; end
            local eyes = LocalPlayer():GetRagdollEntity():GetAttachment( LocalPlayer():GetRagdollEntity():LookupAttachment( "eyes" ) );
            local view = {
                origin = eyes.Pos,
                angles = eyes.Ang,
                fov = 90, 
            };
            return view;
        end
    end
hook.Add( "CalcView", "CalcDeathView", CalcView );

function DeathView()
    if DeathFadeBool then
        if !LocalPlayer():Alive() then
            RunConsoleCommand("pp_texturize", "pp/texturize/plain.png")
        else
            RunConsoleCommand("pp_texturize", "")
        end
    end
end
hook.Add( "Think", "DeathView", DeathView );


if ChatBool then
    Adverts = {"This server is running Gmod Legs " .. GMod_Legs_Ver .. " by Valkyrie and blackops7799", "Get Gmod Legs @ http://steamcommunity.com/sharedfiles/filedetails/?id=112806637"}

    function ChatAdverts ( )
        local text = table.Random(Adverts);
        chat.AddText( Color( 255, 255, 255 ), "[", Color( 0, 255, 25 ), "Gmod Legs", Color( 255, 255, 255 ), "] ", Color( 255, 255, 255 ), text )
    end
    if !game.SinglePlayer() then 
        timer.Create("ChatAdverts", 120, 0, ChatAdverts)
    end
end

if CLIENT then
        surface.CreateFont( "HeaderFont", {
            font        = "coolvetica",
            size        = 25,
            weight      = 500,
            blursize    = 0,
            scanlines   = 0,
            antialias    = true
        } )
        surface.CreateFont( "HeaderFont2", {
            font        = "coolvetica",
            size        = 30,
            weight      = 600,
            antialias    = true
        } )
        surface.CreateFont( "HeaderFont3", {
            font        = "coolvetica",
            size        = 25,
            weight      = 500,
            blursize    = 0,
            scanlines   = 0,
            antialias    = true
        } )

    function Realism()
        if RealMode then
            RunConsoleCommand("mp_falldamage", "0")
            RunConsoleCommand("pp_bloom", "0")
            RunConsoleCommand("pp_toytown", "0")
            RunConsoleCommand("pp_sunbeams", "0")
            RealMode = false            
            MsgN("Realism Off")
        else
            RunConsoleCommand("mp_falldamage", "1")
            RunConsoleCommand("pp_bloom", "1")
            RunConsoleCommand("pp_sunbeams", "1")
            RealMode = true
            MsgN("Realism On")
        end
    end
    concommand.Add("cl_realism",Realism)

    function GModLegsMenu()
        local menu = vgui.Create("DFrame")
        menu:SetSize(ScrW() * 0.65, ScrH() * 0.75)
        menu:SetTitle(" ")
        menu:Center()
        menu:MakePopup()
        menu.Paint = function()
            draw.RoundedBox(0, 0, 0, menu:GetWide(), menu:GetTall(), Color( 0, 0, 0, 150 ) )
            draw.RoundedBox(0, 0, 0, menu:GetWide(), 30, Color(0,0,0,180))
            draw.SimpleTextOutlined("GMod Legs v" .. GMod_Legs_Ver, "HeaderFont", 0+75, 15, Color(0,255,25), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255))    
        end


        local optionsmenu = vgui.Create("DPanel")

        local infopaneltext = vgui.Create("DLabel", optionsmenu)
        infopaneltext:SetText("You Must Start A New Game For Options To Apply")
        infopaneltext:SetColor( Color(255,0,0,255) )
        infopaneltext:SetFont("HeaderFont2")
        infopaneltext:SizeToContents()
        infopaneltext:Dock( TOP )

        local options = vgui.Create("DCheckBoxLabel", optionsmenu)
        options:SetText("Enable Legs?")
        options:Dock( TOP )
        options:SetConVar( "cl_legs" )
        options:SizeToContents()
        options.Paint = function()
            draw.RoundedBox( 0, 0, 0, options:GetWide(), options:GetTall(), Color( 0, 0, 0, 150 ) )
        end

        local options2 = vgui.Create("DCheckBoxLabel", optionsmenu)
        options2:SetText("Enable First Person Death?")
        options2:Dock( TOP )
        options2:SetConVar( "cl_deathview" )
        options2:SizeToContents()
        options2.Paint = function()
            draw.RoundedBox( 0, 0, 0, options2:GetWide(), options2:GetTall(), Color( 0, 0, 0, 150 ) )
        end

        local options3 = vgui.Create("DCheckBoxLabel", optionsmenu)
        options3:SetText("Enable First Person Death Effects?")
        options3:Dock( TOP )
        options3:SetConVar( "cl_deathfade" )
        options3:SizeToContents()
        options3.Paint = function()
            draw.RoundedBox( 0, 0, 0, options3:GetWide(), options3:GetTall(), Color( 0, 0, 0, 150 ) )
        end

        local options4 = vgui.Create("DButton", optionsmenu)
        options4:SetText("Enable Realism")
        options4:Dock( TOP )
        options4:SetSize( 30, 30 )
        options4.DoClick = function()
            if RealMode then
                options4:SetText("Enable Realism")
            else
                options4:SetText("Disable Realism")
            end
            RunConsoleCommand("cl_realism")
        end

        local creditsmenu = vgui.Create("DPanel")

        local infopaneltext = vgui.Create("DLabel", creditsmenu)
        infopaneltext:SetText("GMod Legs v".. GMod_Legs_Ver)
        infopaneltext:SetColor( Color(0,150,255,255) )
        infopaneltext:SetFont("HeaderFont2")
        infopaneltext:SizeToContents()
        infopaneltext:Dock( TOP )

        local label = vgui.Create("DLabel", creditsmenu)
        label:SetText("Valkyrie")
        label:Dock( TOP )
        label:SetFont("HeaderFont3")        
        label:SizeToContents()
        label.Paint = function()
            draw.RoundedBox( 0, 0, 0, label:GetWide(), label:GetTall(), Color( 0, 0, 0, 150 ) )
        end

        local label = vgui.Create("DLabel", creditsmenu)
        label:SetText("blackops7799 - GMod Legs 1.0 - 2.0")
        label:Dock( TOP )
        label:SetFont("HeaderFont3")
        label:SizeToContents()
        label.Paint = function()
            draw.RoundedBox( 0, 0, 0, label:GetWide(), label:GetTall(), Color( 0, 0, 0, 150 ) )
        end

        local tabs = vgui.Create( "DPropertySheet", menu )
        tabs:Dock( FILL )

        tabs:AddSheet("Options", optionsmenu, "icon16/wrench.png")
        tabs:AddSheet("Credits", creditsmenu, "icon16/heart.png")
    end
    concommand.Add("cl_menu",GModLegsMenu)
end