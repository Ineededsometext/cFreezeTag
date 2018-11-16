-- Enumerations

ROUND_WAITING = 0
ROUND_IN_PROGRESS = 1
ROUND_RUNNERS_WIN = 2
ROUND_FREEZER_WIN = 3
ROUND_INTERMISSION = 4

TEAM_RUNNER = 0
TEAM_FREEZER = 1
TEAM_BOTH = 2

-- Master Table

FRZ = FRZ or {}
FRZ.RoundStatus = ROUND_WAITING
FRZ.Abilities = FRZ.Abilities or { 
	Freezer = {}, 
	Runner = {} 
}

-- Teams

team.SetUp( 1, "Runners", Color( 0, 100, 255 ) )
team.SetUp( 2, "Freezer", Color( 255, 25, 0 ) )
team.SetUp( 3, "Spectator", Color( 255, 255, 255 ) )

-- Loading files..

local function LoadCore( dir )
	for k, v in pairs( file.Find( dir .. "/sv_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			include( "core/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/cl_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "core/" .. v )
		else
			include( "core/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/sh_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "core/" .. v )
		end

		include( "core/" .. v )
	end
end

local function LoadModules( dir )
	for k, v in pairs( file.Find( dir .. "/sv_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			include( "modules/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/cl_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "modules/" .. v )
		else
			include( "modules/" .. v )
		end
	end
		
	for k, v in pairs( file.Find( dir .. "/sh_*.lua", "LUA" ) ) do
		if ( SERVER ) then
			AddCSLuaFile( "modules/" .. v )
		end

		include( "modules/" .. v )
	end
end

local function LoadAbilities( dir )
	for k, v in pairs( file.Find( dir .. "/*.lua", "LUA" ) ) do
		Ability = {}
	
		if ( SERVER ) then 
			AddCSLuaFile( "abilities/" .. v ) 
		end
		include( "abilities/" .. v )

		local class = string.gsub( v, ".lua", "" )

		if ( Ability.Team == TEAM_FREEZER ) then
			FRZ.Abilities[ "Freezer" ][ class ] = Ability
		elseif ( Ability.Team == TEAM_RUNNER ) then
			FRZ.Abilities[ "Runner" ][ class ] = Ability
		elseif ( class != "example" ) then
			FRZ.Abilities[ "Freezer" ][ class ] = Ability
			FRZ.Abilities[ "Runner" ][ class ] = Ability
		end
	end

	Ability = nil
end

LoadCore( "cfreezetag/gamemode/cfreezetag/core" )
LoadModules( "cfreezetag/gamemode/cfreezetag/modules" )
LoadAbilities( "cfreezetag/gamemode/cfreezetag/abilities" )

if ( SERVER ) then
    AddCSLuaFile( "cfreezetag/gamemode/cfreezetag/config.lua" )
end

include( "cfreezetag/gamemode/cfreezetag/config.lua" )

-- Finished loading!