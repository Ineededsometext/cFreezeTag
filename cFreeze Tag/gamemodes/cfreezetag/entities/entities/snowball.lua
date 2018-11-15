AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Snowball"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	if ( SERVER ) then
        self:SetTrigger( true )
		self:SetModel( "models/hunter/misc/sphere025x025.mdl" )
        self:SetMaterial( "cfreeze_tag/textures/snow" )
        self:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

        self:PhysicsInit( SOLID_VPHYSICS )
	    self:SetMoveType( MOVETYPE_VPHYSICS )
	    self:SetSolid( SOLID_VPHYSICS )

		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
		end
        
		SafeRemoveEntityDelayed( self, 3 )

        util.SpriteTrail( self, 0, Color( 255, 255, 255 ), false, 40, 10, 0.5, 1 / ( 15 + 1 ) * 0.5, "trails/laser" )
	end

	self.SpawnTime = CurTime()
end

function ENT:StartTouch( ent )
    if ( CLIENT ) then return end

    if ( IsValid( self) and ent:IsPlayer() ) then 
        ent:Freeze( true )
        ent.SnowballHit = true

        timer.Simple( 3, function()
            if ( !IsValid( ent ) ) then return end

            ent:Freeze( false )
            ent.SnowballHit = false
        end )

        timer.Create( "[Snowball] Check if frozen " .. ent:EntIndex(), 0, 0, function()
            if ( IsValid( ent ) and ent.Frozen and ent.SnowballHit ) then
                ent:Freeze( false )
                ent.SnowballHit = false
            end
        end )
    end

    self:Remove() 
end
