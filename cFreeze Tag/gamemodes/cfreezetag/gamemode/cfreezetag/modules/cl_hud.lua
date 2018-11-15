function FRZ.HUDPaint()
    if ( FRZ.Blinded ) then
        draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0, 0, 0 ) )
    end

    for _, ply in pairs( player.GetAll() ) do
        if ( LocalPlayer() != FRZ.Freezer and ply != LocalPlayer() and ply:GetMoveType() != MOVETYPE_NOCLIP or ply == FRZ.Freezer ) then
            local pos = ply:GetPos()

            pos.z = pos.z + ply:OBBMaxs().z

            local sp = pos:ToScreen()

            if ( ply != FRZ.Freezer and ply:GetMoveType() != MOVETYPE_NOCLIP and ply:GetNoDraw() == false ) then
                draw.SimpleText( "v", "RoundInfo", sp.x, sp.y - 10, Color( 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
        end
    end

    draw.RoundedBox( 0, ScrW() * 0.458, ScrH() * 0.04, ScrW() * 0.085, ScrH() * 0.0025, Color( 255, 255, 255, 200 ) )
        
    if ( FRZ.RoundStatus == ROUND_WAITING ) then
        draw.DrawText( "WAITING FOR PLAYERS", "RoundInfo", ScrW() * 0.5, ScrH() * 0.0425, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    elseif ( FRZ.RoundStatus == ROUND_IN_PROGRESS ) then
        if ( FRZ.TimeType == 1 ) then
            draw.DrawText( "BLIND TIME", "RoundInfo", ScrW() * 0.5, ScrH() * 0.0425, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
        else
            draw.DrawText( "TIME LEFT", "RoundInfo", ScrW() * 0.5, ScrH() * 0.0425, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
        end
    elseif ( FRZ.RoundStatus == ROUND_RUNNERS_WIN ) then
        draw.DrawText( "RUNNERS WON!", "RoundInfo", ScrW() * 0.5, ScrH() * 0.0425, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    elseif ( FRZ.RoundStatus == ROUND_FREEZER_WIN ) then
        draw.DrawText( "THE FREEZER WON!", "RoundInfo", ScrW() * 0.5, ScrH() * 0.0425, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    elseif ( FRZ.RoundStatus == ROUND_INTERMISSION ) then
        draw.DrawText( "INTERMISSION", "RoundInfo", ScrW() * 0.5, ScrH() * 0.0425, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    end

    draw.DrawText( string.FormattedTime( FRZ.Time, "%2i:%02i" ), "RoundTime", ScrW() * 0.497, 0, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

    if ( FRZ.AbilitiesEnabled and FRZ.RoundStatus == ROUND_IN_PROGRESS and !FRZ.OnCooldown ) then
        surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
        surface.SetMaterial( Material( tostring( FRZ.AbilityIcon ) ) )

        surface.DrawTexturedRect( ScrW() * 0.89, ScrH() * 0.815, ScrW() * 0.08, ScrH() * 0.13 )

        draw.DrawText( FRZ.AbilityName, "RoundInfo", ScrW() * 0.9215, ScrH() * 0.95, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    elseif ( FRZ.AbilitiesEnabled and FRZ.RoundStatus == ROUND_IN_PROGRESS ) then
        draw.DrawText( math.Round( FRZ.AbilityCooldown ), "RoundTime", ScrW() * 0.9215, ScrH() * 0.9, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

        draw.DrawText( "NEXT ABILITY", "RoundInfo", ScrW() * 0.9215, ScrH() * 0.95, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    end

    if ( FRZ.StaminaEnabled ) then
        if ( FRZ.VeryTired ) then
            draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, 50 * ( ScrW() * 0.0065 ), ScrH() * 0.005, Color( 180, 15, 0, 255 ) )
            
            if ( LocalPlayer() != FRZ.Freezer ) then
                draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, math.Clamp( FRZ.Stamina / FRZ.PlayerStamina, 0, 50 ) * ScrW() * 0.325, ScrH() * 0.005, Color( 255, 50, 0, 255 ) )
            else
                draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, math.Clamp( FRZ.Stamina / FRZ.PlayerStamina * 1.35, 0, 50 ) * ScrW() * 0.325, ScrH() * 0.005, Color( 255, 50, 0, 255 ) )
            end

            surface.SetMaterial( Material( "cfreeze_tag/icons/stamina.png" ) )
            surface.SetDrawColor( Color( 255, 50, 0, 255 ) )

            surface.DrawTexturedRect( ScrW() * 0.477, ScrH() * 0.825, ScrW() * 0.035, ScrH() * 0.065 )

            return
        end

        if ( LocalPlayer():KeyDown( IN_SPEED ) ) then
            FRZ.StaminaLerp = Lerp( FrameTime() * 5, FRZ.StaminaLerp, 255 )
        else
            FRZ.StaminaLerp = Lerp( FrameTime() * 5, FRZ.StaminaLerp, 0 )
        end

        draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, 50 * ( ScrW() * 0.0065 ), ScrH() * 0.005, Color( 180, 180, 180, FRZ.StaminaLerp ) )
        
        if ( LocalPlayer() != FRZ.Freezer ) then
            draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, math.Clamp( FRZ.Stamina / FRZ.PlayerStamina, 0, 50 ) * ScrW() * 0.325, ScrH() * 0.005, Color( 255, 255, 255, FRZ.StaminaLerp ) )
        else
            draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, math.Clamp( FRZ.Stamina / FRZ.PlayerStamina * 1.35, 0, 50 ) * ScrW() * 0.325, ScrH() * 0.005, Color( 255, 255, 255, FRZ.StaminaLerp ) )
        end

        surface.SetMaterial( Material( "cfreeze_tag/icons/stamina.png" ) )
        surface.SetDrawColor( Color( 255, 255, 255, FRZ.StaminaLerp ) )

        surface.DrawTexturedRect( ScrW() * 0.477, ScrH() * 0.825, ScrW() * 0.035, ScrH() * 0.065 )
    end
end
