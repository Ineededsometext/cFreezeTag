-- I'm too lazy to add in comments, you do it.

function GM:Initialize()
    FRZ.Freezer = nil
    FRZ.FrozenPlayers = {}
    FRZ.PlayersLeft = {}
    FRZ.RoundStatus = ROUND_WAITING
end

function GM:PlayerInitialSpawn( ply )
    ply:SetNWInt( "Freezes", 0 )
    ply:SetNWInt( "Thaws", 0 )

    if ( CLIENT ) then return end

    if ( FRZ.RoundStatus == ROUND_IN_PROGRESS ) then
        Spectator( ply )
    end
end

function GM:PlayerSpawn( ply )
    if ( CLIENT ) then return end

    ply:SetModel( "models/player/Group01/male_0" .. math.random( 1, 9 ) .. ".mdl" )
    ply:SetupHands()
    ply:SetPlayerColor( Vector( 1, 1, 1 ) )

    ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    ply:AllowFlashlight( true )

    ply:SetCustomCollisionCheck( true )
    ply.NextAction = CurTime()
end

function GM:PlayerDisconnected( ply )
    if ( ply == FRZ.Freezer ) then
        FRZ.EndRound( ROUND_RUNNERS_WIN, FRZ.IntermissionTime )
    else
        if ( IsValid( FRZ.FrozenPlayers[ ply:EntIndex() ] ) ) then 
            FRZ.FrozenPlayers[ ply:EntIndex() ]:Remove()
        end

        FRZ.FrozenPlayers[ ply:EntIndex() ] = nil
    end
end

function GM:Think()
    if ( FRZ.RoundStatus != ROUND_IN_PROGRESS and FRZ.RoundStatus != ROUND_INTERMISSION and FRZ.RoundStatus != ROUND_RUNNERS_WIN and FRZ.RoundStatus != ROUND_FREEZER_WIN ) then
        if ( table.Count( player.GetAll() ) >= 2 ) then
            FRZ.StartRound( FRZ.RoundTime, FRZ.BlindTime, FRZ.IntermissionTime )
        end
    end

    for _, ply in pairs( player.GetAll() ) do
        if ( IsValid( ply ) and !ply.Frozen and ply != FRZ.Freezer and !table.HasValue( FRZ.PlayersLeft, ply ) ) then
            table.insert( FRZ.PlayersLeft, ply )
        elseif ( IsValid( ply ) and ply.Frozen or ply == FRZ.Freezer ) then
            table.RemoveByValue( FRZ.PlayersLeft, ply )
        end
    end

    if ( table.Count( player.GetAll() ) <= 1 ) then
        for _, ply in pairs( player.GetAll() ) do
            if ( ply == FRZ.Freezer ) then
                FRZ.EndRound( ROUND_FREEZER_WIN, FRZ.IntermissionTime )
            else
                FRZ.EndRound( ROUND_RUNNERS_WIN, FRZ.IntermissionTime )
            end
        end
    end

    if ( table.Count( FRZ.PlayersLeft ) == 0 ) then
        FRZ.EndRound( ROUND_FREEZER_WIN, FRZ.IntermissionTime )
    end

    for _, ply in pairs( player.GetAll() ) do
        for _, plr in pairs( CheckCollision( ply ) ) do
            if ( IsValid( plr:GetOwner() ) and ply != FRZ.Freezer and !ply.Frozen and ply != plr:GetOwner() and ply:GetMoveType() != MOVETYPE_NOCLIP ) then
                FRZ.Thaw( plr:GetOwner(), ply )
			end

			if ( FRZ.RoundStatus == ROUND_IN_PROGRESS and plr:IsPlayer() and ply == FRZ.Freezer and plr:Alive() ) then
				FRZ.Freeze( plr, ply )
			end
        end
    end

    if ( FRZ.AbilitiesEnabled ) then
        for _, ply in pairs( player.GetAll() ) do
            if ( ply:KeyPressed( IN_ATTACK2 ) and ply.Ability != nil and !ply.Frozen and ply:Alive() ) then
                local tr = {
                    start = ply:EyePos(),
                    endpos = ply:EyePos() + ply:EyeAngles():Forward() * 10000,
                    filter = ply
                }

                local trace = util.TraceLine( tr )

                ply.Ability.OnCast( ply, trace )

                ply.Ability.Uses = ply.Ability.Uses - 1

                 if ( ply.Ability != nil and ply.Ability.Uses <= 0 ) then
                    ply.Ability = nil

                    timer.Create( "Ability Cooldown " .. ply:EntIndex(), FRZ.AbilityCooldown, 1 ,function()
                        if ( !IsValid( ply ) or FRZ.RoundStatus != ROUND_IN_PROGRESS ) then return end

                        if ( ply == FRZ.Freezer ) then
                            ply.Ability = table.Random( FRZ.Abilities[ "Freezer" ] )
                        else
                            ply.Ability = table.Random( FRZ.Abilities[ "Runner" ] )
                        end
                    end )
                end
            end
        end
    end
end

function FRZ.Freeze( ply, freezer )
    if ( CLIENT ) then return end
    if ( ply.Frozen or ply.NextAction > CurTime() or ply == freezer or timer.Exists( "Un-Blind Freezer" ) ) then return end

    freezer:SetNWInt( "Freezes", freezer:GetNWInt( "Freezes" ) + 1 )

    ply:EmitSound( "cfreeze_tag/freeze.wav" )

    Spectator( ply )

    local ent = ents.Create( "prop_dynamic" )
    ent:SetModel( ply:GetModel() )
	ent:SetMaterial( "cfreeze_tag/textures/ice", true )
	ent:SetOwner( ply )
	ent:SetPos( ply:GetPos() )
	ent:SetAngles( ply:GetAngles() )
	ent:SetSequence( ply:GetSequence() )

    FRZ.FrozenPlayers[ ply:EntIndex() ] = ent

    ply.Frozen = true
    ply.NextAction = CurTime() + 1
end

function FRZ.Thaw( ply, thawer )
    if ( CLIENT ) then return end
    if ( !ply.Frozen or ply.NextAction > CurTime() or ply == thawer or thawer.Frozen or ply == FRZ.Freezer ) then return end

    thawer:SetNWInt( "Thaws", thawer:GetNWInt( "Thaws" ) + 1 )

    ply:SetMaterial( "" )
    ply:EmitSound( "cfreeze_tag/thaw.wav" )

    UnSpectator( ply )

    if ( IsValid( FRZ.FrozenPlayers[ ply:EntIndex() ] ) ) then
        ply:SetPos( FRZ.FrozenPlayers[ ply:EntIndex() ]:GetPos() )
        ply:SetSequence( FRZ.FrozenPlayers[ ply:EntIndex() ]:GetSequence() )

        FRZ.FrozenPlayers[ ply:EntIndex() ]:Remove()
        FRZ.FrozenPlayers[ ply:EntIndex() ] = nil
    else
        ply:Spawn()
    end

    ply.Frozen = false
    ply.NextAction = CurTime() + 1
end

function FRZ.StartRound( Time, BlindTime, Intermission )
    if ( CLIENT ) then return end

    game.CleanUpMap()

    FRZ.RoundStatus = ROUND_INTERMISSION

    for _, ply in pairs( player.GetAll() ) do
        UnSpectator( ply )
        ply.Frozen = false
    end

    timer.Create( "Update Client info", 0.1, 0, function()
        net.Start( "RoundStatus" )
            net.WriteInt( FRZ.RoundStatus, 32 )
            net.WriteEntity( FRZ.Freezer )
        net.Broadcast()

        net.Start( "Timers" )
            if ( timer.Exists( "Un-Blind Freezer" ) ) then
                net.WriteFloat( timer.TimeLeft( "Un-Blind Freezer" ) )
                net.WriteInt( 1, 32 )
            elseif ( timer.Exists( "Round Timer" ) ) then
                net.WriteFloat( timer.TimeLeft( "Round Timer" ) )
                net.WriteInt( 2, 32 )
            elseif ( timer.Exists( "Round Intermission" ) ) then
                net.WriteFloat( timer.TimeLeft( "Round Intermission" ) )
                net.WriteInt( 3, 32 )
            end
        net.Broadcast()

        for _, ply in pairs( player.GetAll() ) do
            net.Start( "AbilityCD" )
                net.WriteBool( timer.Exists( "Ability Cooldown " .. ply:EntIndex() ) )
                ply:SetNWInt( "Ability Cooldown", timer.TimeLeft( "Ability Cooldown " .. ply:EntIndex() ) )
            net.Send( ply )
        end

        if ( FRZ.StaminaEnabled ) then
            for _, ply in pairs( player.GetAll() ) do
                net.Start( "Stamina" )
                    net.WriteFloat( ply.Stamina )
                    net.WriteBool( ply.VeryTired )
                net.Send( ply )
            end
        end
        
        if ( FRZ.AbilitiesEnabled ) then
            for _, ply in pairs( player.GetAll() ) do
                net.Start( "Ability" )
                    if ( ply.Ability != nil ) then
                        net.WriteString( ply.Ability.Name )
                        net.WriteString( ply.Ability.Icon )
                    end          
                net.Send( ply )
            end
        end
    end )

    timer.Create( "Round Intermission", Intermission, 1, function()
        FRZ.RoundStatus = ROUND_IN_PROGRESS

        for _, ply in pairs( player.GetAll() ) do
            ply:Spawn()

            if ( FRZ.AbilitiesEnabled ) then
                if ( ply == FRZ.Freezer ) then
                    ply.Ability = table.Random( FRZ.Abilities[ "Freezer" ] )
                else
                    ply.Ability = table.Random( FRZ.Abilities[ "Runner" ] )
                end
            end
        end

        FRZ.Freezer = table.Random( player.GetAll() )

        FRZ.Freezer:SetPlayerColor( Vector( 1, 0, 0 ) )
        FRZ.Freezer:SetTeam( 2 )

        FRZ.Freezer:SetWalkSpeed( FRZ.FreezerSpeed )
        FRZ.Freezer:SetRunSpeed( FRZ.FreezerSpeed * 1.25 )

        net.Start( "Blind" )
        net.Send( FRZ.Freezer )
        FRZ.Freezer:Freeze( true )

        for _, ply in pairs( player.GetAll() ) do
            if ( ply != FRZ.Freezer ) then
                ply:SetPlayerColor( Vector( 0, 0, 1 ) )
                ply:SetTeam( 1 )

                ply:SetWalkSpeed( FRZ.RunnerSpeed )
                ply:SetWalkSpeed( FRZ.RunnerSpeed * 1.25 )
            end
        end

        timer.Create( "Un-Blind Freezer", BlindTime, 1, function()
            if ( IsValid( FRZ.Freezer ) ) then
                net.Start( "UnBlind" )
                net.Send( FRZ.Freezer )

                FRZ.Freezer:Freeze( false )
            end

            timer.Create( "Round Timer", Time, 1, function()
                if ( table.Count( FRZ.PlayersLeft ) == 0 ) then
                    FRZ.EndRound( ROUND_FREEZER_WIN, Intermission )
                else
                    FRZ.EndRound( ROUND_RUNNERS_WIN, Intermission )
                end
            end )
        end )
    end )
end

function FRZ.EndRound( Winner, Intermission )
    if ( FRZ.RoundStatus != ROUND_IN_PROGRESS ) then return end

    FRZ.FrozenPlayers = {}
    FRZ.PlayersLeft = {}

    timer.Destroy( "Un-Blind Freezer" )
    timer.Destroy( "Round Timer" )

    FRZ.RoundStatus = Winner
    FRZ.Freezer = nil

    timer.Simple( 10, function()
        FRZ.RoundStatus = ROUND_WAITING

        for _, ply in pairs( player.GetAll() ) do
            ply:Spawn()
            ply:Freeze( false )
            ply:SetModel( "models/player/Group01/male_0" .. math.random( 1, 9 ) .. ".mdl" )
            ply:SetPlayerColor( Vector( 1, 1, 1 ) )

            ply:SetWalkSpeed( FRZ.RunnerSpeed )
            ply:SetRunSpeed( FRZ.RunnerSpeed * 1.25 )

            ply.Ability = nil
        end
    end )
end

if ( SERVER ) then
    util.AddNetworkString( "Blind" )
    util.AddNetworkString( "UnBlind" )
    util.AddNetworkString( "RoundStatus" )
    util.AddNetworkString( "Timers" )
    util.AddNetworkString( "Ability" )
    util.AddNetworkString( "AbilityCD" )
    util.AddNetworkString( "Stamina" )
end

function CheckCollision( ply )
    local z = 72

    if ( ply:Crouching() ) then
        z = 36
    end

	return ents.FindInBox( ply:GetPos() + Vector( -16, -16, 0 ) , ply:GetPos() + Vector( 16, 16, z ) )
end

function Spectator( ply )
    ply:SetMoveType( MOVETYPE_NOCLIP )
    ply:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )
    ply:SetNoDraw( true )
    ply:AllowFlashlight( false )
    ply:Flashlight( false )
end

function UnSpectator( ply )
    ply:SetNoDraw( false )
    ply:SetCollisionGroup( COLLISION_GROUP_WEAPON )
    ply:SetMoveType( MOVETYPE_WALK )
    ply:AllowFlashlight( true )
end

function GM:PlayerShouldTakeDamage()
    return false
end

function GM:PlayerCanPickupWeapon()
    return false
end

function GM:CanPlayerSuicide()
	return false
end