-- To create a HUD, simply overwrite the function "FRZ.HUDPaint".

--[[

ENUMERATIONS:
    * ROUND_WAITING - 0
    * ROUND_IN_PROGRESS - 1
    * ROUND_RUNNERS_WIN - 2
    * ROUND_FREEZER_WIN - 3
    * ROUND_INTERMISSION - 4

IMPORTANT VARIABLES:
    * FRZ.RoundStatus - The current status of the round.
    * FRZ.Time - The time of the round.
    * FRZ.Freezer - The current freezer.
    * FRZ.AbilityName - The name of the ability LocalPlayer() has.
    * LocalPlayer():GetNWInt( "Ability Cooldown" ) - The cooldown until LocalPlayer() gets a new ability.
    * FRZ.OnCooldown - LocalPlayer()'s ability is on cooldown.
    * FRZ.VeryTired - If the player gets 0 stamina and won't be able to sprint until refreshing the stamina bar.
    
FONTS:
    * RoundInfo
    * RoundTime
    * Leaderboard

]]

local function DrawPlayerInfo( ply, y )
    if ( ply != FRZ.Freezer ) then 
        draw.SimpleText( ply:Nick(), "Leaderboard", ScrW() / 2.675, y, Color( 80, 80, 215, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	    draw.SimpleText( ply:Ping(), "Leaderboard", ( ScrW() / 2.675 ) * 1.325, y, Color( 80, 80, 215, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( ply:GetNWInt( "Freezes" ), "Leaderboard", ( ScrW() / 2.675 ) * 1.5, y, Color( 80, 80, 215, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	    draw.SimpleText( ply:GetNWInt( "Thaws" ), "Leaderboard", ( ScrW() / 2.675 ) * 1.675, y, Color( 80, 80, 215, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    else
        draw.SimpleText( ply:Nick(), "Leaderboard", ScrW() / 2.675, y, Color( 215, 80, 80, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	    draw.SimpleText( ply:Ping(), "Leaderboard", ( ScrW() / 2.675 ) * 1.325, y, Color( 215, 80, 80, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( ply:GetNWInt( "Freezes" ), "Leaderboard", ( ScrW() / 2.675 ) * 1.5, y, Color(215, 80, 80, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	    draw.SimpleText( ply:GetNWInt( "Thaws" ), "Leaderboard", ( ScrW() / 2.675 ) * 1.675, y, Color( 215, 80, 80, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end
end

local function DrawPlayerAvatar( ply, x, y )
	local avatar = vgui.Create( "AvatarImage" )
	avatar:SetSize( 32, 32 )
	avatar:SetPos( x, y )
	avatar:SetPlayer( ply, 32 )

    table.insert( FRZ.PlayerAvatars, avatar )
end

function FRZ.HUDPaint()
    if ( FRZ.Blinded ) then
        draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0, 0, 0 ) )
    end

    for _, ply in pairs( player.GetAll() ) do
        if ( ply != LocalPlayer() and ply:GetMoveType() != MOVETYPE_NOCLIP or ply == FRZ.Freezer ) then
            local pos = ply:GetPos()

            pos.z = pos.z + ply:OBBMaxs().z

            local sp = pos:ToScreen()

            if ( LocalPlayer() != FRZ.Freezer and ply != FRZ.Freezer and ply:GetMoveType() != MOVETYPE_NOCLIP and ply:GetNoDraw() == false ) then
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
        draw.DrawText( math.Round( LocalPlayer():GetNWInt( "Ability Cooldown" ) ), "RoundTime", ScrW() * 0.9215, ScrH() * 0.9, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )

        draw.DrawText( "NEXT ABILITY", "RoundInfo", ScrW() * 0.9215, ScrH() * 0.95, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER )
    end

    if ( FRZ.Scoreboard ) then
        draw.RoundedBox( 4, ScrW() / 3, ScrH() / 6, ScrW() / 3, ScrH() / 6 * 4, Color( 225, 225, 225, 225 ) )
        draw.RoundedBox( 4, ScrW() / 3, ScrH() / 6, ScrW() / 3, ScrH() / 6 * 4, Color( 255, 255, 255, 255 ) )
		draw.SimpleText("Freeze Tag", "Leaderboard", ScrW() / 3 + 10, ScrH() / 5.95, Color( 150, 150, 150, 255 ) )
        
		draw.RoundedBox( 3, ScrW() / 3 + 10, ScrH() / 6 + 50, ScrW() / 3 - 20, 38, Color( 200, 200, 200, 255 ) )

        draw.SimpleText( "Name", "Leaderboard", ScrW() / 2.675,  ScrH() / 3.925, Color( 150, 150, 150, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	    draw.SimpleText( "Ping", "Leaderboard", ( ScrW() / 2.675 ) * 1.325, ScrH() / 3.925, Color( 150, 150, 150, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "Freezes", "Leaderboard", ( ScrW() / 2.675 ) * 1.5, ScrH() / 3.925, Color( 150, 150, 150, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        draw.SimpleText( "Thaws", "Leaderboard", ( ScrW() / 2.675 ) * 1.675, ScrH() / 3.925, Color( 150, 150, 150, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        local y = ScrH() / 6 + 90

        for _, ply in pairs( player.GetAll() ) do
            if ( ply != FRZ.Freezer ) then
			    draw.RoundedBox( 3, ScrW() / 3 + 10, y, ScrW() / 3 - 20, 38, Color( 120, 120, 255, 255 ) )
            else
                draw.RoundedBox( 3, ScrW() / 3 + 10, y, ScrW() / 3 - 20, 38, Color( 255, 120, 120, 255 ) )
            end
			DrawPlayerAvatar( ply, ScrW() / 3 + 13, y + 4) 
			DrawPlayerInfo( ply, y + 20 )
            
			y = y + 40
		end
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
            draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, math.Clamp( FRZ.Stamina / FRZ.PlayerStamina, 0, 50 ) * ScrW() * 0.326725, ScrH() * 0.005, Color( 255, 255, 255, FRZ.StaminaLerp ) )
        else
            draw.RoundedBox( 0, ScrW() * 0.335, ScrH() * 0.9, math.Clamp( ( FRZ.Stamina * 1.35 / FRZ.PlayerStamina ), 0, 50 ) * ScrW() * 0.24, ScrH() * 0.005, Color( 255, 255, 255, FRZ.StaminaLerp ) )
        end

        surface.SetMaterial( Material( "cfreeze_tag/icons/stamina.png" ) )
        surface.SetDrawColor( Color( 255, 255, 255, FRZ.StaminaLerp ) )

        surface.DrawTexturedRect( ScrW() * 0.477, ScrH() * 0.825, ScrW() * 0.035, ScrH() * 0.065 )
    end
end