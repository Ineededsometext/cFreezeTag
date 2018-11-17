local num = 0

hook.Add( "PlayerSpawn", "Starting Stamina", function( ply )
    -- Setting player variables.
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

-- Functions to make life easier.
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
        -- Check if the player is out of stamina.
        if ( key == IN_SPEED and ply.Stamina <= 0 or ply.VeryTired ) then
            -- Prevent from running.
            ply:ConCommand( "-speed" )
        end

        -- Sprint spam for stamina saving prevention.
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
    -- Stamina handler.
    if ( FRZ.StaminaEnabled ) then
        local time = CurTime()
        local delta = time - num

        for _, ply in pairs( player.GetAll() ) do
            -- Check if the player is out of stamina.
            if ( ply.Stamina == 0 ) then
                -- Disable the player's sprint until stamina is full.
                ply.VeryTired = true

                ply:EmitSound( "cfreeze_tag/breath.wav" )
            end

            if ( ply.VeryTired ) then 
                if ( ply.Stamina == FRZ.PlayerStamina ) then
                    ply.VeryTired = false
                end
            end

            -- Stamina consumption and regeneration.
            if ( ply:KeyDown( IN_SPEED ) and ply:Alive() and ply:GetVelocity():Length() >= 10 and !ply:Crouching() and !ply.VeryTired and ply:GetMoveType() != MOVETYPE_NOCLIP ) then
                TakeStamina( ply, ( delta * 6 ) )
            elseif ( ply:Alive() and !ply.Sprinted ) then
                AddStamina( ply, ( delta * 2 ) )
            end
        end

        num = time
    end
end )