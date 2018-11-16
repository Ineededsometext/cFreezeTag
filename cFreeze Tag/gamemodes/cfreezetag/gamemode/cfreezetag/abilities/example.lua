-- Creating an ability is simple, this file is about to show you how to create a simple ability!

--[[

ENUMARATIONS:
    * TEAM_FREEZER - 0
    * TEAM_RUNNER - 1
    * TEAM_BOTH - 2

BOOLEANS:
    * PLAYER.Frozen - Is true if the player is frozen.

Ability.Name = "SNOWBALL"                                           -- The name of your ability.
Ability.Icon = "cfreeze_tag/icons/ability_snowball.png"             -- The icon of your ability.
Ability.Team = TEAM_BOTH                                            -- The teams that are able to use it.

Ability.Uses = 1                                                    -- How many uses until the ability dissapears.
Ability.OnCast = function( ply, tr )                                -- What happens if the player right clicks.
    if ( CLIENT or ply.Frozen ) then return end                     -- Check if it's the client or if the player is frozen.

    local snowball = ents.Create( "snowball" )                      -- Create a snowball
    snowball:SetPos( ply:EyePos() + ( ply:GetAimVector() * 16 ) )   -- Set the snowball's position.
    snowball:SetAngles( ply:EyeAngles() )                           -- Set the snowball's angles

    snowball:Spawn()                                                -- Spawn the snowball.

    local phys = snowball:GetPhysicsObject()                        -- Grab the snowball's physics
	local velocity = ply:GetAimVector()                             -- Create a velocity variable.
	velocity = velocity * 8000                                      -- Increase the amount of velocity.
	phys:ApplyForceCenter( velocity )                               -- Apply the velocity
end

]]