if ( FRZ.PushEnabled ) then
	local Sounds = {
		"physics/body/body_medium_impact_hard1.wav",
		"physics/body/body_medium_impact_hard2.wav",
		"physics/body/body_medium_impact_hard3.wav",
		"physics/body/body_medium_impact_hard5.wav",
		"physics/body/body_medium_impact_hard6.wav",
		"physics/body/body_medium_impact_soft5.wav",
		"physics/body/body_medium_impact_soft6.wav",
		"physics/body/body_medium_impact_soft7.wav",
	}

	local RecentPush = {}
		
	hook.Add( "KeyPress", "cFreeze Tag pushing", function( ply, key )
		if ( key == IN_USE and !( RecentPush[ ply:UserID() ] ) ) then
			local ent = ply:GetEyeTrace().Entity
			if ( IsValid( ply ) and IsValid( ent ) ) then
				if ( ply:IsPlayer() and ent:IsPlayer() ) then
					if ( ply:GetPos():Distance( ent:GetPos() ) <= 100 ) then
						if ( ent:Alive() and ent:GetMoveType() == MOVETYPE_WALK ) then
							local Ang = ply:EyeAngles():Forward()
							ent:SetVelocity( Ang * 500 )
							ent:ViewPunch( Angle( math.random( -30, 30 ), math.random( -30, 30 ), 0 ) )

							ent:EmitSound( table.Random( Sounds ) )

							RecentPush[ ply:UserID() ] = true

							timer.Simple( 0.1, function() 
								RecentPush[ ply:UserID() ] = false 
							end )
						end	
					end
				end
			end	
		end
	end)
end