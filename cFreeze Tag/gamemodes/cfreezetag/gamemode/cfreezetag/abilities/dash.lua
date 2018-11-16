Ability.Name = "DASH"
Ability.Icon = "cfreeze_tag/icons/ability_dash.png"
Ability.Team = TEAM_BOTH

Ability.Uses = 1
Ability.OnCast = function( ply, tr )
    if ( CLIENT ) then return end

    local Ang = ply:EyeAngles():Forward()
    ply:SetVelocity( Ang * 1000 )
end