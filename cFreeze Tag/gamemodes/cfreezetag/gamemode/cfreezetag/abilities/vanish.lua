Ability.Name = "VANISH"
Ability.Icon = "cfreeze_tag/icons/ability_vanish.png"
Ability.Team = TEAM_BOTH

Ability.Uses = 1
Ability.OnCast = function( ply, tr )
    ply:SetNoDraw( true )
    ply:PrintMessage( HUD_PRINTCENTER, "You are now invisible for 5 seconds!" )

    timer.Simple( 5, function()
        if ( IsValid( ply ) and !ply.Frozen ) then
            ply:SetNoDraw( false )
            ply:PrintMessage( HUD_PRINTCENTER, "You are no longer invisible." )
        end
    end )
end