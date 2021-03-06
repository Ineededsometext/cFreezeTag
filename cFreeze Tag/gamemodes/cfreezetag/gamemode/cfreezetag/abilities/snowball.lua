Ability.Name = "SNOWBALL"
Ability.Icon = "cfreeze_tag/icons/ability_snowball.png"
Ability.Team = TEAM_BOTH

Ability.Uses = 1
Ability.OnCast = function( ply, tr )
    if ( CLIENT or ply.Frozen ) then return end

    local snowball = ents.Create( "snowball" )
    snowball:SetPos( ply:EyePos() + ( ply:GetAimVector() * 16 ) )
    snowball:SetAngles( ply:EyeAngles() )

    snowball:Spawn()

    local phys = snowball:GetPhysicsObject()
	local velocity = ply:GetAimVector()
	velocity = velocity * 8000
	phys:ApplyForceCenter( velocity )
end