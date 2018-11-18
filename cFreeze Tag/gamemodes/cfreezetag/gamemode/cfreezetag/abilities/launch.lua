Ability.Name = "LAUNCH"
Ability.Icon = "cfreeze_tag/icons/ability_launch.png"
Ability.Team = TEAM_BOTH

Ability.Uses = 1
Ability.OnCast = function( ply, tr )
    if ( CLIENT ) then return end

    ply:SetVelocity( ply:GetAimVector() * 800 )
end
