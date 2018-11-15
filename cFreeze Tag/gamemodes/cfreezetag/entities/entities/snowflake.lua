AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.PrintName = "Snowflake"
ENT.Spawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	if ( SERVER ) then
		self:SetModel( "models/Items/AR2_Grenade.mdl" ) 
		self:PhysicsInitSphere( 1, "wood" )
		self:SetCollisionBounds( Vector( -1, -1, -1 ), Vector( 1, 1, 1 ) )
		self:SetCollisionGroup( COLLISION_GROUP_IN_VEHICLE )

		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake()
			phys:SetBuoyancyRatio( 0 )
			phys:EnableGravity( false )
			phys:EnableDrag( true )
			phys:SetMass( 0 )
		end
		SafeRemoveEntityDelayed( self, 5 )
	end
	self.SpawnTime = CurTime()
end

function ENT:Draw()
	if ( CLIENT ) then
		self:DrawShadow( false )
	end
end

function ENT:DrawTranslucent()
	if ( CLIENT ) then
		self.time = CurTime() - self.SpawnTime
		self.a = 255 - self.time * 1 * 50
		
		cam.Start3D( EyePos(), EyeAngles() )
			render.SetMaterial( Material( "cfreeze_tag/sprites/snowflake.png" ) )
			render.DrawSprite( self:GetPos(), 3, 3, Color(255, 255, 255, self.a) )
		cam.End3D()
	end
end