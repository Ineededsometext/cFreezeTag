local num = 0

hook.Add( "PlayerSpawn", "Starting Stamina", function( ply )
    if ( FRZ.StaminaEnabled ) then
        if ( ply == FRZ.Freezer ) then
            ply.Stamina = FRZ.PlayerStamina * 1.35
        else
            ply.Stamina = FRZ.PlayerStamina
        end
        
        ply.VeryTired = false
        ply.Sprinted = false
    end
end )

function AddStamina( ply, num )
    if ( !ply:Alive() or !FRZ.StaminaEnabled ) then return end

    ply.Stamina = math.Clamp( ply.Stamina + num, 0, 50 )
end

function TakeStamina( ply, num )
    if ( !ply:Alive() or !FRZ.StaminaEnabled ) then return end

    ply.Stamina = math.Clamp( ply.Stamina - num, 0, 50 )
end

hook.Add( "KeyPress", "Stamina Keys", function( ply, key )
    if ( FRZ.StaminaEnabled ) then
        if ( key == IN_SPEED and ply.Stamina <= 0 or ply.VeryTired ) then
            ply:ConCommand( "-speed" )
        end

        if ( key == IN_SPEED and ply:GetVelocity():Length() >= 10 ) then
            ply.Sprinted = true

            if ( !timer.Exists( "Stamina Regen Cooldown " .. ply:EntIndex() ) ) then
                timer.Create( "Stamina Regen Cooldown " .. ply:EntIndex(), 2, 1, function()
                    ply.Sprinted = false
                end )
            else
                timer.Adjust( "Stamina Regen Cooldown " .. ply:EntIndex(), 2, 1, function()
                    ply.Sprinted = false
                end )
            end
        end 
    end
end )

hook.Add( "Think", "Stamina Handler", function()
    if ( FRZ.StaminaEnabled ) then
        local time = CurTime()
        local delta = time - num

        for _, ply in pairs( player.GetAll() ) do
            if ( ply.Stamina == 0 ) then
                ply.VeryTired = true

                ply:EmitSound( "cfreeze_tag/breath.wav" )
            end

            if ( ply.VeryTired ) then 
                if ( ply.Stamina == FRZ.PlayerStamina ) then
                    ply.VeryTired = false
                end
            end

            if ( ply:KeyDown( IN_SPEED ) and ply:Alive() and ply:GetVelocity():Length() >= 10 and !ply:Crouching() and !ply.VeryTired and ply:GetMoveType() != MOVETYPE_NOCLIP ) then
                TakeStamina( ply, ( delta * 6 ) )
            elseif ( ply:Alive() and !ply.Sprinted ) then
                AddStamina( ply, ( delta * 2 ) )
            end
        end

        num = time
    end
end )
